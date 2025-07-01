package com.up.spring.email.model.dao;

import com.up.spring.email.model.dto.PasswordUpdateToken;
import lombok.extern.slf4j.Slf4j;
import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Repository;

@Repository
@Slf4j
public class PasswordUpdateDaoImpl implements PasswordUpdateDao {

    @Override
    public int insertPasswordUpdateToken(SqlSession session, PasswordUpdateToken token) {
        return session.insert("passwordUpdate.insertPasswordUpdateToken", token);
    }

    @Override
    public PasswordUpdateToken selectPasswordUpdateToken(SqlSession session, String token) {
        return session.selectOne("passwordUpdate.selectPasswordUpdateToken", token);
    }

    @Override
    public int updateTokenAsUsed(SqlSession session, String token) {
        return session.update("passwordUpdate.updateTokenAsUsed", token);
    }

    @Override
    public int invalidateExistingTokens(SqlSession session, Long memberNo) {
        return session.update("passwordUpdate.invalidateExistingTokens", memberNo);
    }
} 