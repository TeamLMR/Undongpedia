package com.up.spring.reservation;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class ReservationController {
    @RequestMapping("/reservation.do")
    public String reservationPage() {
        return "reservation/reservation";
    }
}
