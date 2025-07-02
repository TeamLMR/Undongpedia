package com.up.spring.payment.model.service;

import com.up.spring.payment.model.dto.OrderDetails;
import com.up.spring.payment.model.dto.Orders;
import com.up.spring.payment.model.dto.OrdersInvoice;

import java.util.List;
import java.util.Map;

public interface OrderService {
    int isCoursePaidByMember(Orders orders);
    int insertOrder(Orders orders);
    int insertOrderDetails(OrderDetails details);
    int insertOrderAndOrderDetails(Map<String, Object> res, long memberNo, long courseSeq);
    int insertOfflineOrderAndOrderDetails(Map<String, Object> res, long memberNo, long courseSeq, Long scheduleId, String tempReservationId);
    Orders selectOrderById(int ordersSeq);
    List<Orders> selectOrdersByMember(Long memberNo);
    List<OrdersInvoice> selectOrdersByPaymentIdAndMemberNo(Map<String, Object> orders);
    int cancelOrderById(int ordersSeq);
    int cancelOrdersByPaymentId(String paymentId);
}
