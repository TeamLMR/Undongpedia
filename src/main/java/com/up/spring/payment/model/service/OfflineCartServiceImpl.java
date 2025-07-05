package com.up.spring.payment.model.service;

import com.up.spring.payment.model.dao.OfflineCartDao;
import com.up.spring.payment.model.dto.OfflineCart;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
@RequiredArgsConstructor
@Slf4j
public class OfflineCartServiceImpl implements OfflineCartService {

    private final SqlSession sqlSession;
    private final OfflineCartDao offlineCartDao;
    private final com.up.spring.reservation.service.ReservationRedisService reservationRedisService;

    @Override
    public List<OfflineCart> searchOfflineCartByMemberNo(long memberNo) {
        List<OfflineCart> offlineCartList= offlineCartDao.searchOfflineCartByMemberNo(sqlSession, memberNo);
        log.info("오프라인 장바구니 멤버{}, 갯수 {}",memberNo,offlineCartList.size());
        return offlineCartList;
    }

    @Override
    public int addToOfflineCart(long memberNo, OfflineCart offlineCart) {
        offlineCart.setMemberNo(memberNo);
        int result=offlineCartDao.addToOfflineCart(sqlSession, offlineCart);
        if(result>0){
            log.info("오프라인 장바구니 추가 성공");
        }
        return result;
    }

    @Override
    public int deleteOfflineCartByNo(int cartSeq) {
        int result=offlineCartDao.deleteOfflineCartByNo(sqlSession, cartSeq);
        if(result>0){
            log.info("오프라인 장바구니 삭제 성공");
        }
        return result;
    }

    @Override
    public int deleteByTempReservationId(String tempReservationId) {
        int result = offlineCartDao.deleteByTempReservationId(sqlSession, tempReservationId);
        if(result > 0) {
            log.info("임시예약 ID로 오프라인 장바구니 삭제 성공 - tempReservationId: {}, 삭제된 항목 수: {}", 
                    tempReservationId, result);

            // 좌석 복구 및 임시예약 정리
            reservationRedisService.cancelTemporaryReservation(tempReservationId);
        } else {
            log.debug("삭제할 오프라인 장바구니 항목이 없음 - tempReservationId: {}", tempReservationId);
        }
        return result;
    }
}
