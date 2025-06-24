package com.up.spring.security;

import com.up.spring.member.model.dao.MemberDao;
import com.up.spring.member.model.dto.Member;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.ibatis.session.SqlSession;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;

@RequiredArgsConstructor
@Slf4j
public class LoginService implements UserDetailsService {

    private final MemberDao dao;
    private final SqlSession session;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
            log.debug(username);
        Member m = dao.searchById(session, username);
            log.debug("{}",m);
        return m;
    }
}
