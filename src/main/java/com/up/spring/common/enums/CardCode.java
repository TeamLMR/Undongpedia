package com.up.spring.common.enums;


//CardCompanyCode card = CardCompanyCode.fromCode("C0");
//System.out.println(card.getName()); // 신한
public enum CardCode {
    C0("신한"),
    C1("비씨"),
    C3("KB국민"),
    C4("NH농협"),
    C5("롯데"),
    C7("삼성"),
    C9("씨티"),
    CB("우리"),
    CF("하나"),
    CH("현대");

    private final String name;

    CardCode(String name) {
        this.name = name;
    }

    public String getName() {
        return name;
    }

    public static CardCode fromCode(String code) {
        for (CardCode c : values()) {
            if (c.name().equalsIgnoreCase(code)) {
                return c;
            }
        }
        throw new IllegalArgumentException("Unknown card code: " + code);
    }
}
