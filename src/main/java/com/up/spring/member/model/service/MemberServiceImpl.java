package com.up.spring.member.model.service;

import com.up.spring.member.model.dao.MemberDao;
import com.up.spring.member.model.dto.Member;
import lombok.RequiredArgsConstructor;
import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Service;


@Service
@RequiredArgsConstructor
public class MemberServiceImpl implements MemberService {

    private final SqlSession session;


    private final MemberDao memberDaoImpl;

    @Override
    public Member searchById(String memberId) {
        return memberDaoImpl.searchById(session, memberId);
    }
}
