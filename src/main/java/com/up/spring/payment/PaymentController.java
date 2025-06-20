package com.up.spring.payment;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@Slf4j
public class PaymentController {

    @RequestMapping("/cart")
    public String cart() {
        return "payment/cart";
    }
}
