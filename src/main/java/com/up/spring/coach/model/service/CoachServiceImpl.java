package com.up.spring.coach.model.service;

import com.up.spring.coach.model.dao.CoachDao;
import com.up.spring.common.model.dto.Category;
import com.up.spring.course.model.dto.Course;
import com.up.spring.course.model.dto.Curriculum;
import com.up.spring.course.model.dto.Section;
import com.up.spring.coach.model.dto.CoachApply;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.kafka.core.KafkaTemplate;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class CoachServiceImpl implements CoachService {
    private final CoachDao coachDao;
    private final SqlSession sqlSession;
    private final KafkaTemplate<String, Object> kafkaTemplate;

    @Value("${kafka.topic.user-events}")
    private String userEventsTopic;

    @Override
    public Curriculum selectCurrByCurrSeq(long currSeq) {
        return coachDao.selectCurrByCurrSeq(sqlSession, currSeq);
    }

    @Override
    public Section getSection(long courseSeq, long sectionSeq) {
        return coachDao.getSection(sqlSession, courseSeq, sectionSeq);
    }

    @Override
    public int updateTempCourse(Course course) {
        return coachDao.updateTempCourse(sqlSession, course);
    }

    @Override
    public int deleteCurrByCurrSeq(long currSeq) {
        return coachDao.deleteCurrByCurrSeq(sqlSession, currSeq);
    }

    @Override
    public int deleteCurrBySectionSeq(long sectionSeq) {
        return coachDao.deleteCurrBySectionSeq(sqlSession, sectionSeq);
    }

    @Override
    public int deleteSectionByCourseSeq(long courseSeq) {
        return coachDao.deleteSectionByCourseSeq(sqlSession, courseSeq);
    }

    @Override
    public int deleteSectionBySectionSeq(long sectionSeq) {
        return coachDao.deleteSectionBySectionSeq(sqlSession, sectionSeq);
    }

    @Override
    public int updateCurrOrderBySectionSeqAfterDelete(long sectionSeq) {
        return coachDao.updateCurrOrderBySectionSeqAfterDelete(sqlSession, sectionSeq);
    }

    @Override
    public int deleteCourseByCourseSeq(long courseSeq) {
        return coachDao.deleteCourseByCourseSeq(sqlSession, courseSeq);
    }

    @Transactional
    public Map<String,Integer> delCurrAndUpdateCurrOrder(long sectionSeq, long currSeq){
        int deleteResultNum = deleteCurrByCurrSeq(currSeq);
        int updateResultNum = updateCurrOrderBySectionSeqAfterDelete(sectionSeq);
        log.debug("deleteCurrByCurrSeq:{}",deleteResultNum);
        log.debug("updateCurrOrderBySectionSeqAfterDelete:{}",updateResultNum);

        Map<String,Integer> result = new HashMap<>();
        result.put("deleteResult",deleteResultNum);
        result.put("updateResult",updateResultNum);
        return result;
    }

    @Transactional
    public Map<String,Integer> deleteSectionCascade(long courseSeq, long sectionSeq) {
        Section section =  getSection(courseSeq, sectionSeq);
        int deleteSectionNum = 0;
        int deleteCurrNum = 0;

        if (section != null) {
            //커리큘럼 삭제
            int deleteCurrResult = deleteCurrBySectionSeq(section.getSectionSeq());
            if (deleteCurrResult > 0) {
                deleteCurrNum += deleteCurrResult;
            }

            //섹션 삭제
            int deleteSectionBySectionSeq = deleteSectionBySectionSeq(sectionSeq);
            if (deleteSectionBySectionSeq > 0) {
                deleteSectionNum += deleteSectionBySectionSeq;
            }
        }

        Map<String,Integer> result = new HashMap<>();
        result.put("deleteCurrNum",deleteCurrNum);
        result.put("deleteSectionNum",deleteSectionNum);
        return result;
    }

    @Transactional
    public Map<String,Integer> deleteCourseCascade(long courseSeq) {
        List<Section> sectionList =  getSectionList(courseSeq);
        int deleteCurrNum = 0;
        int deleteSectionNum = 0;
        int deleteCourseNum = 0;

        if (!sectionList.isEmpty()) {
            //커리큘럼 삭제
            for (Section section : sectionList) {
                int deleteCurrResult = deleteCurrBySectionSeq(section.getSectionSeq());
                if (deleteCurrResult > 0) {
                    deleteCurrNum += deleteCurrResult;
                }
            }

            //섹션 삭제
            int deleteSectionResult = deleteSectionByCourseSeq(courseSeq);
            if (deleteSectionResult > 0) {
                deleteSectionNum += deleteSectionResult;
            }
        }
        //코스 삭제
        int deleteCourseResult = deleteCourseByCourseSeq(courseSeq);
        if (deleteCourseResult > 0) {
            deleteCourseNum += deleteCourseResult;
        }
        Map<String,Integer> result = new HashMap<>();
        result.put("deleteCurrNum",deleteCurrNum);
        result.put("deleteSectionNum",deleteSectionNum);
        result.put("deleteCourseNum",deleteCourseNum);
        return result;
    }

    @Override
    public List<Category> getCategoryAll() {
        return coachDao.getCategoryAll(sqlSession);
    }
    @Override
    public Long insertTempCourse(Course course) {
        Long courseSeq = coachDao.insertTempCourse(sqlSession, course);

        // 관리자(memberNo=1)에게 코스 승인 요청 알림 이벤트 발행
        try {
            java.util.Map<String, Object> event = new java.util.HashMap<>();
            event.put("memberNo", 1L);
            long ts = System.currentTimeMillis();
            event.put("eventType", "COURSE_APPROVAL_REQUESTED:" + ts);
            event.put("title", "새 코스 승인 요청");
            event.put("message", "새로운 코스( " + course.getCourseTitle() + " ) 승인 요청이 도착했습니다.");
            event.put("link", "admin/courseConfirm");
            kafkaTemplate.send(userEventsTopic, String.valueOf(courseSeq), event);
        } catch (Exception e) {
            log.error("코스 승인 요청 알림 이벤트 발행 실패 courseSeq={} ", courseSeq, e);
        }

        return courseSeq;
    }

    @Override
    public List<Section> getSectionList(Long corseSeq) {
        return coachDao.getSectionList(sqlSession, corseSeq);
    }

    @Override
    public int insertSection(Section section) {
        return coachDao.insertSection(sqlSession, section);
    }
    @Override
    public int insertCurriculum(Curriculum curriculum) {
        return coachDao.insertCurriculum(sqlSession, curriculum);
    }

    @Override
    public List<Map<String, Object>> getDashboardInfo(Long memberNo) {
        return coachDao.getDashboardInfo(sqlSession,memberNo);
    }

    @Override
    public List<Map<String, Object>> getMonthlyEarnings(Long memberNo) {
        return coachDao.getMonthlyEarnings(sqlSession,memberNo);
    }

    @Override
    public List<CoachApply> getCoachApplyList(Map<String, Object> params) {
        return coachDao.selectCoachApplyList(sqlSession, params);
    }

    @Override
    public Map<String, Integer> getCoachApplyCount() {
        log.info("=== getCoachApplyCount 호출됨 ===");
        Map<String, Integer> rawResult = coachDao.selectCoachApplyCount(sqlSession);
        log.info("DB에서 조회한 원본 결과: {}", rawResult);
        
        Map<String, Integer> result = new HashMap<>();
        
        // DB에서 반환되는 컬럼명에 맞춰 매핑 (대문자 키로 반환됨)
        result.put("pending", convertToInteger(rawResult.get("PENDINGCOUNT")));
        result.put("approved", convertToInteger(rawResult.get("APPROVEDCOUNT")));
        result.put("rejected", convertToInteger(rawResult.get("REJECTEDCOUNT")));
        result.put("total", convertToInteger(rawResult.get("TOTALCOUNT")));
        
        log.info("변환된 최종 결과: {}", result);
        return result;
    }
    
    private Integer convertToInteger(Object value) {
        if (value == null) return 0;
        if (value instanceof Number) {
            return ((Number) value).intValue();
        }
        try {
            return Integer.valueOf(value.toString());
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    @Override
    public CoachApply getCoachApplyDetail(Long coaSeq) {
        return coachDao.selectCoachApplyDetail(sqlSession, coaSeq);
    }

    @Override
    @Transactional
    public void updateCoachApplyStatus(Long coaSeq, String status) {
        Map<String, Object> params = new HashMap<>();
        params.put("coaSeq", coaSeq);
        params.put("status", status);
        coachDao.updateCoachApplyStatus(sqlSession, params);

        // 승인 시 신청자에게 알림 전송
        if ("Y".equals(status)) {
            CoachApply apply = coachDao.selectCoachApplyDetail(sqlSession, coaSeq);
            if (apply != null) {
                try {
                    java.util.Map<String, Object> event = new java.util.HashMap<>();
                    event.put("memberNo", apply.getMemberNo());
                    long ts = System.currentTimeMillis();
                    event.put("eventType", "COACH_APPROVED:" + ts);
                    event.put("title", "코치 승인 완료");
                    event.put("message", "코치 신청이 승인되었습니다. 축하합니다!");
                    event.put("link", "coach/dashboard");
                    kafkaTemplate.send(userEventsTopic, "coachApproved:" + coaSeq, event);
                } catch (Exception e) {
                    log.error("코치 승인 알림 이벤트 발행 실패 coaSeq={} ", coaSeq, e);
                }
            }
        }
    }

    @Override
    @Transactional
    public void insertCoachApply(CoachApply coachApply) {
        coachDao.insertCoachApply(sqlSession, coachApply);

        // 관리자(memberNo=1)에게 코치 승인 요청 알림 이벤트 발행
        try {
            log.info("코치 승인 요청 알림 이벤트 발행 시작 - userEventsTopic: {}", userEventsTopic);
            
            java.util.Map<String, Object> event = new java.util.HashMap<>();
            event.put("memberNo", 1L);
            long ts2 = System.currentTimeMillis();
            event.put("eventType", "COACH_APPROVAL_REQUESTED:" + ts2);
            event.put("title", "새 코치 승인 요청");
            event.put("message", "새로운 코치 승인 요청이 도착했습니다.");
            event.put("link", "admin/coachConfirm");
            
            log.info("이벤트 데이터: {}", event);
            kafkaTemplate.send(userEventsTopic, "coachApply:" + coachApply.getMemberNo(), event);
            log.info("코치 승인 요청 알림 이벤트 발행 완료");
        } catch (Exception e) {
            log.error("코치 승인 요청 알림 이벤트 발행 실패 memberNo={} ", coachApply.getMemberNo(), e);
        }
    }
}
