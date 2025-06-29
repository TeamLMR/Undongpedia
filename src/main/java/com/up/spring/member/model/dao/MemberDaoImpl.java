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

    @Override
    public int saveMember(SqlSession session, Member member) {
        return session.insert("member.saveMember", member);
    }

    @Override
    public int updateMember(SqlSession session, Member member) {
        return 0;
    }
}
