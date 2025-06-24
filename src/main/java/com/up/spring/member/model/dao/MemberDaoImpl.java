package com.up.spring.member.model.dao;

import com.up.spring.member.model.dto.Member;
import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Repository;

@Repository
public class MemberDaoImpl implements MemberDao {
    @Override
    public Member searchById(SqlSession session, String memberId) {
        return session.selectOne("member.searchById", memberId);
    }
}
