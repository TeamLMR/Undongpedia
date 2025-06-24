package com.up.spring.member.model.dao;

import com.up.spring.member.model.dto.Member;
import org.apache.ibatis.session.SqlSession;

public interface MemberDao {
    Member searchById(SqlSession session, String memberId);

}
