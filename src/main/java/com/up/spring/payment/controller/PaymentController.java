package com.up.spring.payment.controller;

import com.up.spring.course.model.dto.Course;
import com.up.spring.member.model.dto.Member;
import com.up.spring.payment.model.dto.Cart;
import com.up.spring.payment.model.dto.NaverProperty;
import com.up.spring.payment.model.service.CartService;
import lombok.NoArgsConstructor;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.*;

import static io.lettuce.core.GeoArgs.Unit.m;

@RequiredArgsConstructor
@Controller
@Slf4j
public class PaymentController {
    private final CartService cartService;
    private final NaverProperty naverProperty;

    private Map<String, Object> setNaverPayMap(List<String> productNames,
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
        String loc = "/";
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
        String loc = "/";
        long memberNo = returnMemberNo();
        if (memberNo != 0) {
            List<Cart> cartList = cartService.searchCartsByMemberNo(memberNo);
            model.addAttribute("cartList", cartList);
            loc = "payment/cart";
        } else {
            model.addAttribute("msg", "잘못된 접근입니다");
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

            /*
             * 1. 카트 내 장바구니 리스트 가져오기
             * 2. 이름, 갯수, 총 가격 합쳐서
             * 3. 결제
             * */
            HttpHeaders headers = new HttpHeaders();
            headers.set("X-Naver-Client-Id", naverProperty.getXNaverClientId());
            headers.set("X-Naver-Client-Secret", naverProperty.getXNaverClientSecret());
            headers.set("Content-Type", "application/json");

            List<Cart> cartList =  cartService.searchCartsByMemberNo(memberNo);
            List<String> cartNames = new ArrayList<>();
            int productCount = cartList.size();
            int totalPayAmount = 0;
            for (Cart cart : cartList) {
                cartNames.add(cart.getCartCourse().getCourseTitle());
                int coursePrice = cart.getCartCourse().getCoursePrice();
                double discountPrice = (double) (coursePrice * (100 - cart.getCartCourse().getCourseDiscount())) /100;
                log.debug("discountPrice: " + discountPrice + " coursePrice: " + coursePrice);
                totalPayAmount += (int) (discountPrice);
            }

            Map<String, Object> oPayMap = setNaverPayMap(cartNames, productCount, totalPayAmount, request);
            model.addAttribute("oPayMap", oPayMap);

        } else {

        }
        return "payment/start";
    }

    @RequestMapping("/payment/end")
    public String paymentEnd(@RequestParam("resultCode") String resultCode, @RequestParam("paymentId") String paymentId,
    @RequestParam(value = "resultMessage", required = false) String resultMessage,  @RequestParam(value = "reserveId", required = false) String reserveId, Model model) {
        String loc = "common/msg";
        String msg = "";
        log.debug("resultCode:{}", resultCode);
        log.debug("paymentId:{}", paymentId);
        log.debug("reserveId:{}", reserveId);
        log.debug("resultMessage:{}", resultMessage);

        /*만약 결제 성공*/
        if (resultCode.equals("Success")) {
            loc = "mypage";

        } else {
            /*만약 결제 실패*/
            if (resultMessage.isEmpty()){
                msg = resultMessage;
            } else {
                msg  = "알 수 없는 오류입니다.";
            }
            model.addAttribute("msg", resultMessage);
            model.addAttribute("loc", loc);
        }
        return "redirect:/" + loc;
    }
}
