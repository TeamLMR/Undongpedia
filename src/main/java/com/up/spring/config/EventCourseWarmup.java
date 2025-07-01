package com.up.spring.config;


import com.up.spring.reservation.dao.CourseReservationConfigDao;
import com.up.spring.reservation.service.CourseReservationConfigService;
import com.up.spring.reservation.service.ScheduleCacheService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationListener;
import org.springframework.context.annotation.Lazy;
import org.springframework.context.event.ContextRefreshedEvent;
import org.springframework.stereotype.Component;

@Component
@Slf4j
public class EventCourseWarmup implements ApplicationListener<ContextRefreshedEvent> {

    @Autowired
    @Lazy
    private  ScheduleCacheService scheduleCacheService;

    @Autowired
    @Lazy
    private  CourseReservationConfigService courseReservationConfigService;

    private boolean initialized = false;
    @Override
    public void onApplicationEvent(ContextRefreshedEvent event) {
        if(!initialized && event.getApplicationContext().getParent() == null) {
            initialized = true;

            log.info("이벤트 강의 캐시 워밍업");

            courseReservationConfigService.getAllConfigs().stream()
                    .filter(config -> config.getIsActiveBoolean())
                    .forEach(config -> {
                        scheduleCacheService.warmUpCache(config.getCourseSeq());
                        log.info("{} 워밍업완료", config.getCourseSeq());
                    });
            log.info("이벤트 워밍업 완료 ");
        }
    }
}
