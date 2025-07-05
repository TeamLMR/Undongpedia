package com.up.spring.payment.model.dao;

import com.up.spring.payment.model.dto.OrderDetails;
import com.up.spring.payment.model.dto.Orders;
import com.up.spring.payment.model.dto.OrdersInvoice;
import lombok.RequiredArgsConstructor;
import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository

public class OrdersDaoImpl implements OrdersDao {

    @Override
    public List<OrdersInvoice> selectOrdersByPaymentIdAndMemberNo(SqlSession session, Map<String, Object> orders) {
        return session.selectList("selectOrdersByPaymentIdAndMemberNo", orders);
    }

    @Override
    public int cancelOrdersByPaymentId(SqlSession session, String paymentId) {
        return session.update("cancelOrdersByPaymentId", paymentId);
    }

    @Override
    public int isCoursePaidByMember(SqlSession session, Orders orders) {
        return session.selectOne("orders.isCoursePaidByMember", orders);
    }

    @Override
    public int cancelOrderById(SqlSession session, int ordersSeq) {
        return session.update("cancelOrderById", ordersSeq);
    }

    @Override
    public int insertOrder(SqlSession session, Orders order) {
        return session.insert("insertOrder", order);
    }

    @Override
    public int insertOfflineOrder(SqlSession session, Orders order) {
        return session.insert("insertOfflineOrder", order);
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

    @Override
    public int existsScheduleReservation(SqlSession sqlSession, Map<String, Object> params) {
        return sqlSession.selectOne("orders.existsScheduleReservation", params);
    }
}
