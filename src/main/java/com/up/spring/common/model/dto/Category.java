package com.up.spring.common.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class Category {
    private int cateSeq;
    private String cateKey;
    private String cateValue;
    private String cateIcon;
    private String cateDesc;
}
