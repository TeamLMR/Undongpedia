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

    public long returnMemberNo(){
        String loc = "/";
        Member m = (Member) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        long memberNo = 0;
        if (m != null){
            memberNo = m.getMemberNo();
        }
        return memberNo;
    }

    @RequestMapping("/cart/remove")
    public String removeCart(@RequestParam("removeCartSeq") int removeSeq, Model model) {
        String loc = "/";
        log.debug("removeCart" + removeSeq);
        long memberNo = returnMemberNo();
        if (memberNo != 0) {
            List<Cart> cartList = cartService.searchCartsByMemberNo(memberNo);
            log.info("cartList: {}", cartList);
            model.addAttribute("cartList", cartList);
            loc = "payment/cart";
        } else {
            model.addAttribute("msg", "잘못된 접근입니다");
            loc = "common/msg";
        }
        return loc;
    }

    @RequestMapping("/cart")
    public String cart(Model model, HttpSession session) {
        String loc = "/";
        long memberNo = returnMemberNo();
        if (memberNo != 0) {
            List<Cart> cartList = cartService.searchCartsByMemberNo(memberNo);
            log.info("cartList: {}", cartList);
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
        HttpHeaders headers = new HttpHeaders();
        headers.set("X-Naver-Client-Id", naverProperty.getXNaverClientId());
        headers.set("X-Naver-Client-Secret", naverProperty.getXNaverClientSecret());
        headers.set("Content-Type", "application/json");

        Map<String, Object> oPayMap = new HashMap<>();
        //mode, clientId, chainId
        oPayMap.put("mode", naverProperty.getMode());
        oPayMap.put("clientId", naverProperty.getXNaverClientId());
        oPayMap.put("chainId", naverProperty.getXNaverPayChainId());
        oPayMap.put("merchantPayKey", naverProperty.getMerchantKey());

        //결제창 오픈시 들어갈 정보들
        //TODO: 여기 아래부터는 프로덕트 정보들 (임시정보)
        //TODO: 추후에 디비 정보 들어가게해야함 url제외하고..
        oPayMap.put("productName", "필라테스");
        oPayMap.put("productCount", "1");
        oPayMap.put("totalPayAmount", "10000");
        oPayMap.put("taxScopeAmount", "10000");
        oPayMap.put("taxExScopeAmount", "0");
        String url = request.getScheme() + "://"+ request.getServerName() + ":" + request.getServerPort() + request.getContextPath();
        log.debug(url);
        oPayMap.put("returnUrl",  url + "/payment/end");
        model.addAttribute("oPayMap", oPayMap);

        return "payment/start";
    }

    @RequestMapping("/payment/end")
    public String paymentEnd(@RequestParam("resultCode") String resultCode, @RequestParam("paymentId") String paymentId,
    @RequestParam(value = "resultMessage", required = false) String resultMessage,  @RequestParam(value = "reserveId", required = false) String reserveId) {

        log.debug("resultCode:{}", resultCode);
        log.debug("paymentId:{}", paymentId);
        log.debug("reserveId:{}", reserveId);
        log.debug("resultMessage:{}", resultMessage);
        return "payment/end";
    }
}
