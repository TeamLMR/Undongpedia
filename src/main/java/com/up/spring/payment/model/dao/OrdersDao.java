package com.up.spring.payment.model.dao;

import com.up.spring.payment.model.dto.OrderDetails;
import com.up.spring.payment.model.dto.Orders;
import com.up.spring.payment.model.dto.OrdersInvoice;
import org.apache.ibatis.session.SqlSession;
import org.springframework.core.annotation.Order;

import java.util.List;
import java.util.Map;

public interface OrdersDao {
    int insertOrder(SqlSession session, Orders orders);
    int insertOfflineOrder(SqlSession session, Orders order);
    int insertOrderDetails(SqlSession session, OrderDetails details);
    Orders selectOrderById(SqlSession session, int ordersSeq);
    List<Orders> selectOrdersByMember(SqlSession session, Long memberNo);
    List<OrdersInvoice> selectOrdersByPaymentIdAndMemberNo(SqlSession session, Map<String, Object> orders);
    int cancelOrderById(SqlSession session, int ordersSeq);
    int isCoursePaidByMember(SqlSession session, Orders orders);
    int cancelOrdersByPaymentId(SqlSession session, String paymentId);
}