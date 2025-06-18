package com.up.spring.common;

import org.apache.ibatis.type.JdbcType;
import org.apache.ibatis.type.TypeHandler;

import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class StringToArray implements TypeHandler<String[]> {

    @Override
    public void setParameter(PreparedStatement ps, int i, String[] parameter, JdbcType jdbcType) throws SQLException {
        if(parameter!=null){
            ps.setString(i, String.join(",",parameter));
        }else{
            ps.setString(i,null);
        }
    }

    @Override
    public String[] getResult(ResultSet rs, String columnName) throws SQLException {
        String result = rs.getString(columnName);
        if(result==null){
            return result.split(",");
        }
        return null;
    }

    @Override
    public String[] getResult(ResultSet rs, int columnIndex) throws SQLException {
        String result = rs.getString(columnIndex);
        if(result==null){
            return result.split(",");
        }
        return null;
    }

    @Override
    public String[] getResult(CallableStatement cs, int columnIndex) throws SQLException {
        String result = cs.getString(columnIndex);
        if(result==null){
            return result.split(",");
        }
        return null;
    }
}
