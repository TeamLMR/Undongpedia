package com.up.spring.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.HandlerExceptionResolver;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;
import org.springframework.web.servlet.config.annotation.ViewControllerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import org.springframework.web.servlet.handler.SimpleMappingExceptionResolver;

import java.util.Properties;

@Configuration //설정클래스를 선언하는 어노테이션 == springbean-configuration.xml
@EnableWebMvc //mvc:annotation-driven 설정과 동일
public class MyWebAppConfig implements WebMvcConfigurer {
//    화면전환용 매핑메소드 한번에 적용하기
    @Override
    public void addViewControllers(ViewControllerRegistry registry) {
//        registry.addViewController("/enrollmember.do").setViewName("member/memberEnroll");
    }

    //    ExceptionHandler
    @Bean
    public HandlerExceptionResolver exceptionResolver() {
        Properties prop = new Properties();

//        prop.setProperty(IllegalArgumentException.class.getName(),"common/error/error1");
//        prop.setProperty(NumberFormatException.class.getName(),"common/error/error2");

        SimpleMappingExceptionResolver exceptionResolver = new SimpleMappingExceptionResolver();

        exceptionResolver.setExceptionMappings(prop);

        return exceptionResolver;
    }
}
