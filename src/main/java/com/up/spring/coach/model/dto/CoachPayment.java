package com.up.spring.coach.model.dto;

import lombok.*;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class CoachPayment {
    long courseSeq;
    String courseTitle;
    int coursePrice;
    int courseDiscount;
    int memberCount;
    int orderCount;
}
