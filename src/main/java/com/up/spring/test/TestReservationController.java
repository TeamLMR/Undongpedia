package com.up.spring.test;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/test")
@RequiredArgsConstructor
public class TestReservationController {

    @GetMapping("/reservation")
    public String testPage() {
        return "test/reservation";
    }
} 