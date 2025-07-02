package com.up.spring.payment.model.service;

import com.up.spring.payment.model.dto.OrderDetails;
import com.up.spring.payment.model.dto.Orders;

import java.util.List;
import java.util.Map;

public interface OrderService {
    int isCoursePaidByMember(Orders orders);
    int insertOrder(Orders orders);
    int insertOrderDetails(OrderDetails details);
    int insertOrderAndOrderDetails(Map<String, Object> res, long memberNo, int courseSeq);
    int insertOfflineOrderAndOrderDetails(Map<String, Object> res, long memberNo, int courseSeq, Long scheduleId, String tempReservationId);
    Orders selectOrderById(int ordersSeq);
    List<Orders> selectOrdersByMember(Long memberNo);
    int cancelOrderById(int ordersSeq);
}
