package com.up.spring.payment.model.dao;


import com.up.spring.payment.model.dto.OfflineCart;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class OfflineCartDaoImpl implements OfflineCartDao {

    @Override
    public List<OfflineCart> searchOfflineCartByMemberNo(SqlSession sqlSession, long memberNo) {
        return sqlSession.selectList("offlineCart.searchOfflineCartsByMemberNo", memberNo);
    }

    @Override
    public int addToOfflineCart(SqlSession sqlSession, OfflineCart offlineCart) {
        return sqlSession.insert("offlineCart.insertOfflineCart", offlineCart);
    }

    @Override
    public int deleteOfflineCartByNo(SqlSession sqlSession, int cartSeq) {
        return sqlSession.delete("offlineCart.deleteOfflineCartBySeq", cartSeq);
    }

    @Override
    public int deleteByTempReservationId(SqlSession sqlSession, String tempReservationId) {
        return sqlSession.delete("offlineCart.deleteOfflineCartByTempReservationId", tempReservationId);
    }
}
