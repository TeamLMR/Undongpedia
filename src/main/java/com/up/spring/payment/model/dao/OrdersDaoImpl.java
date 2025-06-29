package com.up.spring.payment.model.dao;

import com.up.spring.payment.model.dto.OrderDetails;
import com.up.spring.payment.model.dto.Orders;
import lombok.RequiredArgsConstructor;
import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository

public class OrdersDaoImpl implements OrdersDao {
    @Override
    public int insertOrder(SqlSession session, Orders order) {
        return session.insert("insertOrder", order);
    }

    @Override
    public int insertOrderDetails(SqlSession session, OrderDetails details) {
        return session.insert("insertOrderDetails", details);
    }

    @Override
    public Orders selectOrderById(SqlSession session, int ordersSeq) {
        return session.selectOne("selectOrderById", ordersSeq);
    }

    @Override
    public List<Orders> selectOrdersByMember(SqlSession session, Long memberNo) {
        return session.selectList("selectOrdersByMember", memberNo);
    }
}
