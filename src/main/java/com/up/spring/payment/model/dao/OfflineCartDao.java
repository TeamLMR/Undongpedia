package com.up.spring.payment.model.dao;

import com.up.spring.payment.model.dto.OfflineCart;
import org.apache.ibatis.session.SqlSession;

import java.util.List;

public interface OfflineCartDao {
    List<OfflineCart> searchOfflineCartByMemberNo(SqlSession sqlSession,long memberNo);
    int addToOfflineCart(SqlSession sqlSession, OfflineCart offlineCart);
    int deleteOfflineCartByNo(SqlSession sqlSession, int cartSeq);
    int deleteByTempReservationId(SqlSession sqlSession, String tempReservationId);
}
