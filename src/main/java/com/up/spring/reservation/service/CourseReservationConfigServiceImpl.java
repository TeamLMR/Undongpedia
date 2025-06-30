package com.up.spring.reservation.service;

import com.up.spring.course.model.dto.Course;
import com.up.spring.course.model.service.CourseService;
import com.up.spring.reservation.dao.CourseReservationConfigDao;
import com.up.spring.reservation.dto.CourseReservationConfig;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Timestamp;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
@RequiredArgsConstructor
@Slf4j
public class CourseReservationConfigServiceImpl implements CourseReservationConfigService {

    private final CourseReservationConfigDao configDao;
    private final CourseService courseService;
    private final SqlSession sqlSession;

    @Override
    public Optional<CourseReservationConfig> getConfigByCourseSeq(Long courseSeq) {
        try {
            CourseReservationConfig config = configDao.selectByCourseSeq(sqlSession, courseSeq);
            return Optional.ofNullable(config);
        } catch (Exception e) {
            log.error("이벤트 설정 조회 실패 - courseSeq: {}", courseSeq, e);
            return Optional.empty();
        }
    }

    @Override
    public CourseReservationConfig getConfigByConfigId(Long configId) {
        return configDao.selectByConfigId(sqlSession, configId);
    }

    @Override
    public List<CourseReservationConfig> getAllConfigs() {
        return configDao.selectAll(sqlSession);
    }

    @Override
    public String getReservationMode(Long courseSeq) {
        try {
            Course course = courseService.searchById(courseSeq);
            if (course == null) {
                return "NORMAL";
            }
            
            // course_type이 EVENT인 경우에만 이벤트 설정 확인
            if ("EVENT".equals(course.getCourseType())) {
                Optional<CourseReservationConfig> config = getConfigByCourseSeq(courseSeq);
                return config.isPresent() && config.get().getIsActiveBoolean() ? "EVENT" : "NORMAL";
            }
            
            return course.getCourseType(); // ON, OFF, EVENT
        } catch (Exception e) {
            log.error("예약 모드 확인 실패 - courseSeq: {}", courseSeq, e);
            return "NORMAL";
        }
    }

    @Override
    public boolean isEventCourse(Long courseSeq) {
        return "EVENT".equals(getReservationMode(courseSeq));
    }

    @Override
    public boolean isOpenTime(Long courseSeq) {
        Optional<CourseReservationConfig> config = getConfigByCourseSeq(courseSeq);
        return config.map(CourseReservationConfig::isOpenNow).orElse(true);
    }

    @Override
    public boolean canEnterWaitingRoom(Long courseSeq) {
        Optional<CourseReservationConfig> config = getConfigByCourseSeq(courseSeq);
        return config.map(CourseReservationConfig::canEnterWaitingRoom).orElse(false);
    }

    @Override
    public int getMaxConcurrentUsers(Long courseSeq) {
        return getConfigByCourseSeq(courseSeq)
                .map(CourseReservationConfig::getMaxConcurrentUsers)
                .orElse(20); // 기본값
    }

    @Override
    public List<CourseReservationConfig> getCoursesToOpen() {
        Timestamp now = new Timestamp(System.currentTimeMillis());
        return configDao.selectCoursesToOpen(sqlSession, now);
    }

    @Override
    public List<CourseReservationConfig> getWaitingRoomAvailableCourses() {
        Timestamp now = new Timestamp(System.currentTimeMillis());
        return configDao.selectWaitingRoomAvailable(sqlSession, now);
    }

    @Override
    public boolean createConfig(CourseReservationConfig config) {
        try {
            // 기본값 설정
            if (config.getMaxConcurrentUsers() == null) {
                config.setMaxConcurrentUsers(20);
            }
            if (config.getWaitingRoomOpenMinutes() == null) {
                config.setWaitingRoomOpenMinutes(10);
            }
            if (config.getIsActive() == null) {
                config.setIsActive("Y");
            }
            
            int result = configDao.insert(sqlSession, config);
            log.info("이벤트 설정 생성 - courseSeq: {}, 성공: {}", config.getCourseSeq(), result > 0);
            return result > 0;
        } catch (Exception e) {
            log.error("이벤트 설정 생성 실패 - courseSeq: {}", config.getCourseSeq(), e);
            return false;
        }
    }

    @Override
    public boolean updateConfig(CourseReservationConfig config) {
        try {
            int result = configDao.update(sqlSession, config);
            log.info("이벤트 설정 수정 - configId: {}, 성공: {}", config.getConfigId(), result > 0);
            return result > 0;
        } catch (Exception e) {
            log.error("이벤트 설정 수정 실패 - configId: {}", config.getConfigId(), e);
            return false;
        }
    }

    @Override
    public boolean deleteConfig(Long configId) {
        try {
            int result = configDao.delete(sqlSession, configId);
            log.info("이벤트 설정 삭제 - configId: {}, 성공: {}", configId, result > 0);
            return result > 0;
        } catch (Exception e) {
            log.error("이벤트 설정 삭제 실패 - configId: {}", configId, e);
            return false;
        }
    }

    @Override
    public boolean activateConfig(Long configId) {
        try {
            int result = configDao.updateActive(sqlSession, configId, "Y");
            log.info("이벤트 설정 활성화 - configId: {}, 성공: {}", configId, result > 0);
            return result > 0;
        } catch (Exception e) {
            log.error("이벤트 설정 활성화 실패 - configId: {}", configId, e);
            return false;
        }
    }

    @Override
    public boolean deactivateConfig(Long configId) {
        try {
            int result = configDao.updateActive(sqlSession, configId, "N");
            log.info("이벤트 설정 비활성화 - configId: {}, 성공: {}", configId, result > 0);
            return result > 0;
        } catch (Exception e) {
            log.error("이벤트 설정 비활성화 실패 - configId: {}", configId, e);
            return false;
        }
    }
} 