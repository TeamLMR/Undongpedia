package com.up.spring.payment.controller;

import com.up.spring.member.model.dto.Member;
import com.up.spring.payment.model.dto.Cart;
import com.up.spring.payment.model.dto.NaverProperty;
import com.up.spring.payment.model.dto.OfflineCart;
import com.up.spring.payment.model.dto.Orders;
import com.up.spring.payment.model.service.CartService;
import com.up.spring.payment.model.service.OfflineCartService;
import com.up.spring.payment.model.service.OrderService;
import com.up.spring.course.model.dto.Course;
import com.up.spring.course.model.dto.CourseSchedule;
import com.up.spring.course.model.service.CourseService;
import com.up.spring.course.model.service.CourseScheduleService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.*;

@RequiredArgsConstructor
@Controller
@Slf4j
public class PaymentController {
    private final CartService cartService;
    private final NaverProperty naverProperty;
    private final OrderService orderService;
    private final OfflineCartService offlineCartService;
    private final CourseService courseService;
    private final CourseScheduleService courseScheduleService;
    private final RedisTemplate<String, Object> redisTemplate;

    private List<String> getCartCourseNames(long memberNo){
        List<String> cartNames = new ArrayList<>();
        
        // 온라인 장바구니
        List<Cart> cartList = cartService.searchCartsByMemberNo(memberNo);
        for (Cart cart : cartList) {
            cartNames.add(cart.getCartCourse().getCourseTitle());
        }
        
        // 오프라인 장바구니
        List<OfflineCart> offlineCartList = offlineCartService.searchOfflineCartByMemberNo(memberNo);
        for (OfflineCart offlineCart : offlineCartList) {
            String courseName = offlineCart.getCartCourse().getCourseTitle();
            cartNames.add(courseName + " (오프라인 예약)");
        }
        
        return cartNames;
    }

    private int[] getCartCountAndPrice(long memberNo){
        int productCount = 0;
        int totalPayAmount = 0;
        
        // 온라인 장바구니
        List<Cart> cartList = cartService.searchCartsByMemberNo(memberNo);
        productCount += cartList.size();
        
        for (Cart cart : cartList) {
            int coursePrice = cart.getCartCourse().getCoursePrice();
            double discountPrice = (double) (coursePrice * (100 - cart.getCartCourse().getCourseDiscount())) /100;
            totalPayAmount += (int) (discountPrice);
        }
        
        // 오프라인 장바구니
        List<OfflineCart> offlineCartList = offlineCartService.searchOfflineCartByMemberNo(memberNo);
        productCount += offlineCartList.size();
        
        for (OfflineCart offlineCart : offlineCartList) {
            int coursePrice = offlineCart.getCartCourse().getCoursePrice();
            double discountPrice = (double) (coursePrice * (100 - offlineCart.getCartCourse().getCourseDiscount())) /100;
            totalPayAmount += (int) (discountPrice);
        }

        return new int[]{productCount, totalPayAmount};
    }


    private HttpHeaders getHeaders(String type) {
        HttpHeaders headers = new HttpHeaders();
        headers.set("X-Naver-Client-Id", naverProperty.getXNaverClientId());
        headers.set("X-Naver-Client-Secret", naverProperty.getXNaverClientSecret());
        switch (type) {
            case "start":{
                headers.set("Content-Type", "application/json");
            }
            case "end": {
                headers.set("X-NaverPay-Chain-Id", naverProperty.getXNaverPayChainId());
                headers.set("X-NaverPay-Idempotency-Key", UUID.randomUUID().toString());
                headers.set("Content-Type", "application/x-www-form-urlencoded");
            }
        }
        return headers;
    }

    private Map<String, Object> setNaverPayMap(
            List<String> productNames,
            int productCount,
            int totalPayAmount, HttpServletRequest request){
        Map<String, Object> oPayMap = new HashMap<>();

        //네이버는 이름에 건수를 자동 처리를 해주네.. 참고
        String joinNames = "";
        if (productNames.isEmpty()) {
            joinNames = "상품 없음"; // 기본값 설정
        } else {
            joinNames = productNames.get(0);
        }
        log.debug(joinNames);

        //부가세 (10%)
        int taxScopeAmount = 0;

        //총 금액 - 부가세(10%) 한 금액
        int applyPayAmount = 0;
        taxScopeAmount = (int) (totalPayAmount * 0.1);
        applyPayAmount = totalPayAmount - taxScopeAmount;

        log.debug("joinNames: " + joinNames + " taxScopeAmount: " +  taxScopeAmount + " applyPayAmount: " + applyPayAmount +" totalPayAmount: " +  totalPayAmount);

        //mode, clientId, chainId
        oPayMap.put("mode", naverProperty.getMode());
        oPayMap.put("clientId", naverProperty.getXNaverClientId());
        oPayMap.put("chainId", naverProperty.getXNaverPayChainId());
        oPayMap.put("merchantPayKey", naverProperty.getMerchantKey());

        oPayMap.put("productName", joinNames);
        oPayMap.put("productCount", productCount);
        oPayMap.put("totalPayAmount", totalPayAmount);
        oPayMap.put("taxScopeAmount", taxScopeAmount);
        oPayMap.put("taxExScopeAmount", applyPayAmount);

        String url = request.getScheme() + "://"+ request.getServerName() + ":" + request.getServerPort() + request.getContextPath();
        log.debug(url);
        oPayMap.put("returnUrl",  url + "/payment/end");
        return oPayMap;
    }

    public long returnMemberNo(){
        Member m = (Member) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        long memberNo = 0;
        if (m != null){
            memberNo = m.getMemberNo();
        }
        return memberNo;
    }
    @PostMapping("/cart/add")
    public String addCart(@RequestParam("addCourseSeq") long courseSeq, Model model, RedirectAttributes redirectAttributes) {
        String loc = "common/msg";
        log.debug("courseSeq: {}", courseSeq);
        long memberNo = returnMemberNo();
        if  (memberNo != 0){
            //중복 확인
            Cart cart = Cart.builder()
                    .memberNo(memberNo)
                    .courseSeq(courseSeq)
                    .build();

            int count = cartService.isCourseInCart(cart);
            //이미 클래스가 존재한다면
            if (count > 0){
                redirectAttributes.addAttribute("result", "fail");
                redirectAttributes.addAttribute("msg", "이미 장바구니에 존재합니다.");
                loc = "redirect:/";
                //없다면 insert
            } else {
                int result = cartService.insertCart(cart);
                if(result == 1){
                    redirectAttributes.addAttribute("result", "success");
                    redirectAttributes.addAttribute("msg", "장바구니에 담았습니다.");
                    loc = "redirect:/";
                } else {
                    redirectAttributes.addAttribute("result", "fail");
                    redirectAttributes.addAttribute("msg", "장바구니에 담지 못했습니다.");
                    loc = "redirect:/";
                }
            }

        } else {
            model.addAttribute("msg", "로그인을 확인해주세요.");
            model.addAttribute("loc", "/");
        }

        return loc;
    }

    @PostMapping("/cart/remove")
    public String removeCart(@RequestParam("removeCartSeq") int removeCartSeq, Model model) {
        String loc = "common/msg";
        log.debug("removeCartSeq: {}", removeCartSeq);

        long memberNo = returnMemberNo();
        if (memberNo != 0) {
            /*
            * 1. 멤버 세션이 있을 때만
            * 2. 삭제시 값 받아서 확인
            * 3. 온라인 장바구니에서 먼저 시도, 실패하면 오프라인 장바구니에서 시도
            * 4. 다시 카트 리스트 가져와서 반환
            * */
            
            // 먼저 온라인 장바구니에서 삭제 시도
            int deleteCartResult = cartService.deleteCartByNo(removeCartSeq);
            

            if (deleteCartResult != 1) {
                deleteCartResult = offlineCartService.deleteOfflineCartByNo(removeCartSeq);
                log.debug("오프라인 장바구니 삭제 결과: {}", deleteCartResult);
            }
            
            if (deleteCartResult == 1) {
                //삭제 성공시 카트 리스트 반환하도록 다시 위치 보냄
                loc = "redirect:/cart";
            } else {
                //삭제 실패시 메세지 페이지
                model.addAttribute("msg", "장바구니 상품 삭제가 실패했습니다.");
                model.addAttribute("loc", "/cart");
            }

        } else {
            model.addAttribute("msg", "잘못된 접근입니다");
            model.addAttribute("loc", "/cart");
        }
        return loc;
    }

    @RequestMapping("/cart")
    public String cart(Model model, HttpSession session) {
        String loc = "common/msg";
        long memberNo = returnMemberNo();
        if (memberNo != 0) {
            List<Cart> cartList = cartService.searchCartsByMemberNo(memberNo);
            List<OfflineCart> offlineCartList = offlineCartService.searchOfflineCartByMemberNo(memberNo);
            model.addAttribute("cartList", cartList);
            model.addAttribute("offlineCartList", offlineCartList);
            loc = "payment/cart";
        } else {
            model.addAttribute("msg", "잘못된 접근입니다");
            model.addAttribute("loc", "/");
        }
        return loc;
    }

    @RequestMapping("/payment/orderinvoice")
    public String orderInvoice(@RequestParam("id") int ordersSeq, Model model){
        String loc = "common/msg";
        Orders orders = orderService.selectOrderById(ordersSeq);
        if (orders != null) {
            model.addAttribute("orders", orders);
            loc = "payment/orderInvoice";
        } else {
            model.addAttribute("msg", "문제가 있습니다.");
            model.addAttribute("loc", "/mypage");
        }
        return loc;
    }

    @RequestMapping("/payment/cancel")
    public String paymentCancel(@RequestParam("id") int ordersSeq, Model model) {
        String loc = "common/msg";
        
        // 주문 취소 전에 주문 정보 조회 (좌석 복구를 위해)
        Orders cancelOrder = orderService.selectOrderById(ordersSeq);
        
        int result = orderService.cancelOrderById(ordersSeq);
        if (result == 1) {
            // 오프라인 예약인 경우 스케줄 좌석 복구
            if (cancelOrder != null && cancelOrder.getScheduleId() != null) {
                try {
                    boolean seatRestoreResult = courseScheduleService.cancelSeat(cancelOrder.getScheduleId());
                    if (seatRestoreResult) {
                        log.info("주문 취소 시 좌석 복구 성공 - ordersSeq: {}, scheduleId: {}", ordersSeq, cancelOrder.getScheduleId());
                        // 좌석 복구 성공 시 관련 캐시 무효화
                        invalidateScheduleCache(cancelOrder.getCourseSeq(), cancelOrder.getScheduleId());
                    } else {
                        log.error("주문 취소 시 좌석 복구 실패 - ordersSeq: {}, scheduleId: {}", ordersSeq, cancelOrder.getScheduleId());
                    }
                } catch (Exception e) {
                    log.error("주문 취소 시 좌석 복구 중 오류 발생 - ordersSeq: {}, scheduleId: {}", ordersSeq, cancelOrder.getScheduleId(), e);
                }
            }
            loc = "redirect:/mypage/purchaseHistory";
        } else {
            model.addAttribute("msg", "문제가 있습니다.");
            model.addAttribute("loc", "/mypage");
        }
        return loc;
    }

    @RequestMapping("/payment/start")
    public String paymentStart(Model model, HttpServletRequest request) {
        String loc = "/";
        long memberNo = returnMemberNo();
        if (memberNo != 0) {
            //결제창 오픈시 들어갈 정보들
            //카트 내 장바구니들 전체 결제
            List<String> cartNames = getCartCourseNames(memberNo);
            int[] countAndPrice = getCartCountAndPrice(memberNo);
            
            // 장바구니가 비어있는지 확인
            if (countAndPrice[0] == 0) {
                model.addAttribute("msg", "장바구니에 상품이 없습니다.");
                model.addAttribute("loc", "/cart");
                loc = "common/msg";
            } else {
                HttpHeaders headers = getHeaders("start");
                Map<String, Object> oPayMap = setNaverPayMap(cartNames, countAndPrice[0], countAndPrice[1], request);
                model.addAttribute("oPayMap", oPayMap);
                loc = "payment/start";
            }
        } else {
            model.addAttribute("msg", "잘못된 접근입니다");
            model.addAttribute("loc", "/cart");
        }
        return loc;
    }

    @RequestMapping("/payment/end")
    public String paymentEnd(@RequestParam("resultCode") String resultCode, @RequestParam("paymentId") String paymentId,
    @RequestParam(value = "resultMessage", required = false) String resultMessage,  @RequestParam(value = "reserveId", required = false) String reserveId, Model model) {
        String loc = "common/msg";
        String msg = "";
        boolean isInsertSuccess = true;
        boolean isCartDeleteSuccess = true;

        log.debug("resultCode:{}", resultCode);
        log.debug("paymentId:{}", paymentId);
        log.debug("reserveId:{}", reserveId);
        log.debug("resultMessage:{}", resultMessage);

        //현재 멤버 세션이 확인되면
        long memberNo = returnMemberNo();
        if (memberNo != 0) {
            //resultcode가 Success였으면
            if (resultCode.equals("Success")) {
                //헤더 세팅
                HttpHeaders headers = getHeaders("end");

                //httpEntity에 넣을 파라미터 세팅
                MultiValueMap<String, Object> payParams = new LinkedMultiValueMap<>();
                payParams.add("paymentId", paymentId);
                /* https://{API 도메인} / {파트너 ID} / naverpay / payments / {API 버전} / {API명} */
                String url = "https://" + naverProperty.getApiDomain() + "/" +
                        naverProperty.getParterId() +
                        "/naverpay/payments/" +
                        naverProperty.getApiVersion() + "/" +
                        naverProperty.getApiName();

                //요청결과
                RestTemplate restTemplate = new RestTemplate();
                HttpEntity<?> request = new HttpEntity<>(payParams, headers);
                Map<String, Object> res = restTemplate.postForObject(url, request, Map.class);

                //TODO: 너무 길어지니까 나중에 분리 ㄱㄱ
                //res가 존재하고, code가 성공일때
                log.debug("res:{}", res);

                if (res != null && res.get("code").equals("Success")) {
                    //온라인 카트 리스트만큼 반복
                    List<Cart> cartList = cartService.searchCartsByMemberNo(memberNo);
                    if (!cartList.isEmpty()) {
                        for (int i = 0; i < cartList.size(); i++) {
                            long courseSeq = cartList.get(i).getCourseSeq();
                            int resResult = orderService.insertOrderAndOrderDetails(res, memberNo, courseSeq);
                            //만약 실패하면 바로 메세지창으로 던짐
                            if (resResult != 1) {
                                isInsertSuccess = false;
                                break;
                            }
                        }
                    }
                    
                    //오프라인 카트 리스트 처리 (추가)
                    List<OfflineCart> offlineCartList = offlineCartService.searchOfflineCartByMemberNo(memberNo);
                    if (!offlineCartList.isEmpty() && isInsertSuccess) {
                        for (int i = 0; i < offlineCartList.size(); i++) {
                            OfflineCart offlineCart = offlineCartList.get(i);
                            int courseSeq = offlineCart.getCartCourse().getCourseSeq().intValue();
                            Long scheduleId = offlineCart.getCartCourseSchedule().getScheduleId();
                            String tempReservationId = offlineCart.getTempReservationId();
                            
                            // 주문 저장
                            int resResult = orderService.insertOfflineOrderAndOrderDetails(res, memberNo, courseSeq, scheduleId, tempReservationId);
                            if (resResult != 1) {
                                isInsertSuccess = false;
                                break;
                            }
                            
                            // 스케줄 좌석 차감 (결제 완료 시)
                            try {
                                boolean seatResult = courseScheduleService.reserveSeat(scheduleId);
                                if (!seatResult) {
                                    log.error("스케줄 좌석 차감 실패 - scheduleId: {}, tempReservationId: {}", scheduleId, tempReservationId);
                                    // 좌석 차감 실패 시에도 주문은 유지 (수동 처리 가능)
                                } else {
                                    log.info("스케줄 좌석 차감 성공 - scheduleId: {}, tempReservationId: {}", scheduleId, tempReservationId);
                                    // 좌석 차감 성공 시 관련 캐시 무효화
                                    invalidateScheduleCache(courseSeq, scheduleId);
                                }
                            } catch (Exception e) {
                                log.error("스케줄 좌석 차감 중 오류 발생 - scheduleId: {}, tempReservationId: {}", scheduleId, tempReservationId, e);
                            }
                        }
                    }
                    
                    //TODO:완료시 카트 삭제까지
                    //아 이거 다시 반복 안시키고싶은디 그리고 이거 분리시켜야할것같
                    if (isInsertSuccess) {
                        // 온라인 장바구니 삭제
                        for (int i = 0; i < cartList.size(); i++) {
                            int cartSeq = cartList.get(i).getCartSeq();
                            int deleteCartResult = cartService.deleteCartByNo(cartSeq);
                            if (deleteCartResult != 1) {
                                isCartDeleteSuccess = false;
                                break;
                            }
                        }
                        
                        // 오프라인 장바구니 삭제 (추가)
                        if (isCartDeleteSuccess) {
                            for (int i = 0; i < offlineCartList.size(); i++) {
                                int cartSeq = offlineCartList.get(i).getCartSeq();
                                int deleteOfflineCartResult = offlineCartService.deleteOfflineCartByNo(cartSeq);
                                if (deleteOfflineCartResult != 1) {
                                    isCartDeleteSuccess = false;
                                    break;
                                }
                            }
                        }
                    }

                    if (isInsertSuccess && isCartDeleteSuccess) {
                        log.debug("isInsertSuccess:{}", isInsertSuccess);
                        log.debug("isCartDeleteSuccess:{}", isCartDeleteSuccess);
                        log.info("온라인 장바구니 {}개, 오프라인 장바구니 {}개 결제 완료", cartList.size(), offlineCartList.size());
                        loc = "redirect:/mypage";
                    }
                }

            } else {
                /*만약 결제 실패*/
                if (resultMessage.isEmpty()){
                    msg = resultMessage;
                } else {
                    msg  = "결제를 실패했습니다.";
                }
                model.addAttribute("msg", resultMessage);
                model.addAttribute("loc", "/cart");
            }
        } else {
            msg  = "원인을 알 수 없습니다.";
            model.addAttribute("msg", msg);
            model.addAttribute("loc", "/cart");
        }

        return loc;
    }

    //오프라인 장바구니
    @PostMapping("/cart/add-offline")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> addOfflineCart(
            @RequestParam String tempReservationId,
            @RequestParam Long scheduleId,
            @RequestParam Long courseSeq) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            long memberNo = returnMemberNo();
            if (memberNo == 0) {
                response.put("success", false);
                response.put("message", "로그인이 필요합니다.");
                return ResponseEntity.badRequest().body(response);
            }

            Course course = courseService.searchById(courseSeq);
            if (course == null) {
                response.put("success", false);
                response.put("message", "강의 정보를 찾을 수 없습니다.");
                return ResponseEntity.badRequest().body(response);
            }

            List<CourseSchedule> schedules = courseScheduleService.searchScheduleByCourseSeq(courseSeq);
            CourseSchedule targetSchedule = schedules.stream()
                    .filter(schedule -> schedule.getScheduleId().equals(scheduleId))
                    .findFirst()
                    .orElse(null);
            
            if (targetSchedule == null) {
                response.put("success", false);
                response.put("message", "스케줄 정보를 찾을 수 없습니다.");
                return ResponseEntity.badRequest().body(response);
            }
            
            // OfflineCart 객체 생성
            OfflineCart offlineCart = OfflineCart.builder()
                    .memberNo(memberNo)
                    .tempReservationId(tempReservationId)
                    .cartCourse(course)
                    .cartCourseSchedule(targetSchedule)
                    .build();

            int result = offlineCartService.addToOfflineCart(memberNo, offlineCart);
            
            if (result > 0) {
                response.put("success", true);
                response.put("message", "장바구니에 추가되었습니다.");
                log.info("오프라인 장바구니 추가 성공 - memberNo: {}, tempReservationId: {}, scheduleId: {}", 
                        memberNo, tempReservationId, scheduleId);
            } else {
                response.put("success", false);
                response.put("message", "장바구니 추가에 실패했습니다.");
            }
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("오프라인 장바구니 추가 중 오류 발생", e);
            response.put("success", false);
            response.put("message", "서버 오류가 발생했습니다.");
            return ResponseEntity.internalServerError().body(response);
        }
    }

    /**
     * 스케줄 관련 캐시 무효화 (성능 최적화)
     */
    private void invalidateScheduleCache(int courseSeq, Long scheduleId) {
        try {
            // 단일 키 삭제 (성능 우선)
            String[] directKeys = {
                "course:available-dates:" + courseSeq,
                "schedule:capacity:" + scheduleId
            };
            
            for (String key : directKeys) {
                Boolean deleted = redisTemplate.delete(key);
                if (Boolean.TRUE.equals(deleted)) {
                    log.debug("캐시 키 삭제: {}", key);
                }
            }
            
            // 패턴 매칭은 SCAN으로 안전하게 처리 (제한적)
            String pattern = "course:timeslots:" + courseSeq + ":*";
            org.springframework.data.redis.core.ScanOptions scanOptions = 
                org.springframework.data.redis.core.ScanOptions.scanOptions()
                    .match(pattern)
                    .count(10) // 제한적으로만 처리
                    .build();
            
            try (org.springframework.data.redis.core.Cursor<String> cursor = redisTemplate.scan(scanOptions)) {
                int deleteCount = 0;
                while (cursor.hasNext() && deleteCount < 20) { // 최대 20개만 삭제
                    String key = cursor.next();
                    redisTemplate.delete(key);
                    deleteCount++;
                }
                if (deleteCount > 0) {
                    log.debug("캐시 패턴 삭제: {} ({}개 키)", pattern, deleteCount);
                }
            }
            
            log.debug("스케줄 캐시 무효화 완료 - courseSeq: {}, scheduleId: {}", courseSeq, scheduleId);
            
        } catch (Exception e) {
            log.error("캐시 무효화 중 오류 발생 - courseSeq: {}, scheduleId: {}", courseSeq, scheduleId, e);
        }
    }
}
