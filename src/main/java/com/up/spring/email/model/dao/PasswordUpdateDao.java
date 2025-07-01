package com.up.spring.email.model.dao;

import com.up.spring.email.model.dto.PasswordUpdateToken;
import org.apache.ibatis.session.SqlSession;

public interface PasswordUpdateDao {
    int insertPasswordUpdateToken(SqlSession session, PasswordUpdateToken token);
    PasswordUpdateToken selectPasswordUpdateToken(SqlSession session, String token);
    int updateTokenAsUsed(SqlSession session, String token);
    int invalidateExistingTokens(SqlSession session, Long memberNo);
} 