package com.up.spring.payment.controller;

import com.up.spring.member.model.dto.Member;
import com.up.spring.payment.model.dto.Cart;
import com.up.spring.payment.model.dto.NaverProperty;
import com.up.spring.payment.model.service.CartService;
import com.up.spring.payment.model.service.OrderService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.client.RestTemplate;

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

    private List<String> getCartCourseNames(long memberNo){
        List<Cart> cartList =  cartService.searchCartsByMemberNo(memberNo);
        List<String> cartNames = new ArrayList<>();

        for (Cart cart : cartList) {
            cartNames.add(cart.getCartCourse().getCourseTitle());
        }
        return cartNames;
    }

    private int[] getCartCountAndPrice(long memberNo){
        List<Cart> cartList =  cartService.searchCartsByMemberNo(memberNo);
        int productCount = cartList.size();
        int totalPayAmount = 0;

        for (Cart cart : cartList) {
            int coursePrice = cart.getCartCourse().getCoursePrice();
            double discountPrice = (double) (coursePrice * (100 - cart.getCartCourse().getCourseDiscount())) /100;
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
        joinNames = productNames.get(0);
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

    @PostMapping("/cart/remove")
    public String removeCart(@RequestParam("removeCartSeq") int removeCartSeq, Model model) {
        String loc = "common/msg";
        log.debug("removeCartSeq" + removeCartSeq);

        long memberNo = returnMemberNo();
        if (memberNo != 0) {
            /*
            * 1. 멤버 세션이 있을 때만
            * 2. 삭제시 값 받아서 확인
            * 3. 다시 카트 리스트 가져와서 반환
            * */
            int deleteCartResult = cartService.deleteCartByNo(removeCartSeq);
            if(deleteCartResult == 1){
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
            model.addAttribute("cartList", cartList);
            loc = "payment/cart";
        } else {
            model.addAttribute("msg", "잘못된 접근입니다");
            model.addAttribute("loc", "/");
            loc = "common/msg";
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
            HttpHeaders headers = getHeaders("start");
            List<String> cartNames = getCartCourseNames(memberNo);
            int[] countAndPrice = getCartCountAndPrice(memberNo);

            Map<String, Object> oPayMap = setNaverPayMap(cartNames, countAndPrice[0], countAndPrice[1], request);
            model.addAttribute("oPayMap", oPayMap);
            loc = "payment/start";
        } else {
            model.addAttribute("msg", "잘못된 접근입니다");
            model.addAttribute("loc", "/common/msg");
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
                    //카트 리스트만큼 반복
                    List<Cart> cartList = cartService.searchCartsByMemberNo(memberNo);
                    if (!cartList.isEmpty()) {
                        for (int i = 0; i < cartList.size(); i++) {
                            int courseSeq = cartList.get(i).getCourseSeq();
                            int resResult = orderService.insertOrderAndOrderDetails(res, memberNo, courseSeq);
                            //만약 실패하면 바로 메세지창으로 던짐
                            if (resResult != 1) {
                                isInsertSuccess = false;
                                break;
                            }
                        }
                        //TODO:완료시 카트 삭제까지
                        //아 이거 다시 반복 안시키고싶은디 그리고 이거 분리시켜야할것같
                        if (isInsertSuccess) {
                            for (int i = 0; i < cartList.size(); i++) {
                                int cartSeq = cartList.get(i).getCartSeq();
                                int deleteCartResult = cartService.deleteCartByNo(cartSeq);
                                if (deleteCartResult != 1) {
                                    isCartDeleteSuccess = false;
                                    break;
                                }
                            }
                        }

                        if (isInsertSuccess && isCartDeleteSuccess) {
                            log.debug("isInsertSuccess:{}", isInsertSuccess);
                            log.debug("isCartDeleteSuccess:{}", isCartDeleteSuccess);
                            loc = "redirect:/mypage";
                        }
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
}
