package com.up.spring.payment.model.service;

import com.up.spring.course.model.dto.Course;
import com.up.spring.payment.model.dto.OfflineCart;

import java.util.List;

public interface OfflineCartService {
    List<OfflineCart> searchOfflineCartByMemberNo(long memberNo);
    int addToOfflineCart(long memberNo, OfflineCart offlineCart);
    int deleteOfflineCartByNo(int cartSeq);
    int deleteByTempReservationId(String tempReservationId);

}
