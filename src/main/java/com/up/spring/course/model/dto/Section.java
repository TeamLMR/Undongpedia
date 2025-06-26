package com.up.spring.course.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class Section {
    private String sectionSeq;
    private String sectionTitle;
    private String sectionContent;
    private String sectionOrder;
    private String courseSeq;
    private List<Curriculum> curriculums;
}
