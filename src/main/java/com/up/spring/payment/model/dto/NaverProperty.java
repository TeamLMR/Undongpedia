package com.up.spring.payment.model.dto;

import lombok.Getter;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.PropertySource;
import org.springframework.stereotype.Component;

@Component
@Getter
@PropertySource("classpath:properties/api/naverapi.properties")
public class NaverProperty {
    @Value("${x.naver.client.id}")
    private String xNaverClientId;

    @Value("${x.naver.client.secret}")
    private String xNaverClientSecret;

    @Value("${x.naverpay.chain.id}")
    private String XNaverPayChainId;

    @Value("${dev.naver.domain}")
    private String domain;

    @Value("${x.merchant.pay.key}")
    private String merchantKey;

    @Value("${mode}")
    private String mode;

    @Value("dev-pub.apis.naver.com")
    private String apiDomain;

    @Value("v2")
    private String apiVersion;

    @Value("apply/payment")
    private String apiName;

    @Value("naverpay-partner")
    private String parterId;
}
