package com.up.spring.security;

import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AccountExpiredException;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.DisabledException;
import org.springframework.security.authentication.LockedException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.authentication.AuthenticationFailureHandler;
import org.springframework.security.web.authentication.session.SessionAuthenticationException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@Slf4j
public class AuthFailureHandler implements AuthenticationFailureHandler {

    @Override
    public void onAuthenticationFailure(HttpServletRequest request, HttpServletResponse response, AuthenticationException exception) throws IOException, ServletException {
        log.debug("에러 {}{}",exception,exception.getMessage());
        String msg="";
        if(exception instanceof BadCredentialsException){

        }else if(exception instanceof DisabledException){

        }else if(exception instanceof LockedException){

        }else if(exception instanceof AccountExpiredException){

        }else if(exception instanceof SessionAuthenticationException){
            msg="중복 로그인이 있습니다.";
        }
        request.setAttribute("msg", msg);
        request.getRequestDispatcher("/loginpage").forward(request, response);
    }
}
