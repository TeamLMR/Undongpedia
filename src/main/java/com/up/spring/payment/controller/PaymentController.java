package com.up.spring.payment.controller;

import com.up.spring.payment.dto.NaverProperty;
import lombok.NoArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.Map;

@NoArgsConstructor
@Controller
@Slf4j
public class PaymentController {

    @Autowired
    private NaverProperty naverProperty;

    @RequestMapping("/cart")
    public String cart() {
        return "payment/cart";
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
