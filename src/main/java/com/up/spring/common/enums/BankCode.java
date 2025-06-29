package com.up.spring.common.enums;

//BankCode bank = BankCode.fromCode("090");
//System.out.println(bank.getDescription()) // 카카오뱅크
public enum BankCode {
    KDB("002", "산업은행"),
    IBK("003", "기업은행"),
    KB("004", "국민은행"),
    KOOKMIN_FOREIGN("005", "외환은행"),
    SUHYUP("007", "수협"),
    NH("011", "농협"),
    LOCAL_NH("012", "지역농·축협"),
    WOORI("020", "우리은행"),
    SC("023", "SC제일은행"),
    CITI("027", "씨티은행"),
    IMBANK("031", "iM뱅크"),
    BUSAN("032", "부산은행"),
    GWANGJU("034", "광주은행"),
    JEJU("035", "제주은행"),
    JEONBUK("037", "전북은행"),
    GYEONGNAM("039", "경남은행"),
    MG("045", "새마을금고"),
    SHINHYUP("048", "신협"),
    SAVINGS_BANK("050", "저축은행"),
    POST("071", "우체국"),
    HANA("081", "하나은행"),
    SHINHAN("088", "신한은행"),
    K_BANK("089", "케이뱅크"),
    KAKAO_BANK("090", "카카오뱅크"),
    TOSS_BANK("092", "토스뱅크"),
    DAE_SHIN_SB("102", "대신저축은행"),
    SBI_SB("103", "에스비아이저축은행"),
    HK_SB("104", "에이치케이저축은행"),
    WELCOME_SB("105", "웰컴저축은행"),
    SHINHAN_SB("106", "신한저축은행"),
    YUANTA("209", "유안타증권"),
    KB_SEC("218", "KB증권"),
    SANGSANGIN("221", "상상인증권"),
    HANYANG("222", "한양증권"),
    READING("223", "리딩투자증권"),
    BNK_SEC("224", "BNK투자증권"),
    IBK_SEC("225", "IBK투자증권"),
    DAOL("227", "다올투자증권"),
    MIRAED("238", "미래에셋"),
    SAMSUNG("240", "삼성증권"),
    KOREA_INVEST("243", "한국투자증권"),
    NH_INVEST("247", "NH투자증권"),
    KYOBO("261", "교보증권"),
    HI_INVEST("262", "하이투자증권"),
    HYUNDAI_MOTOR("263", "현대차증권"),
    KIWOOM("264", "키움증권"),
    EBEST("265", "이베스트투자증권"),
    SK_SEC("266", "SK증권"),
    DAE_SHIN("267", "대신증권"),
    HANWHA("269", "한화증권"),
    HANA_INVEST("270", "하나금융투자"),
    SHINHAN_INVEST("278", "신한금융투자"),
    DB_INVEST("279", "DB금융투자"),
    EUGENE("280", "유진투자증권"),
    MERITZ("287", "메리츠증권"),
    KAKAO_PAY("288", "카카오페이증권"),
    BUGUK("290", "부국증권"),
    SHINYOUNG("291", "신영증권"),
    CAPE("292", "케이프투자증권"),
    KOREA_SEC_FINANCE("293", "한국증권금융"),
    WOORI_OLD("294", "우리투자증권(구포스)"),
    WOORI_INVEST("295", "우리투자증권");

    private final String code;
    private final String description;

    BankCode(String code, String description) {
        this.code = code;
        this.description = description;
    }

    public String getCode() {
        return code;
    }

    public String getDescription() {
        return description;
    }

    public static BankCode fromCode(String code) {
        for (BankCode b : values()) {
            if (b.code.equals(code)) {
                return b;
            }
        }
        throw new IllegalArgumentException("Unknown bank code: " + code);
    }
}

