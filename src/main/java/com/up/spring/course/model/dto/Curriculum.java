package com.up.spring.course.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.web.multipart.MultipartFile;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class Curriculum {
    private Long currSeq;
    private String currTitle;
    private String currVideoUrl;
    private MultipartFile currVideoFile;
    private String currVideoType;
    private String currPreview;
    private int currOrder;
    private Long sectionSeq;
}
