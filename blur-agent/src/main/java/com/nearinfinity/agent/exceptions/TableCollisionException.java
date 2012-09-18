package com.nearinfinity.agent.exceptions;

@SuppressWarnings("serial")
public class TableCollisionException extends CollisionException{
  public TableCollisionException(int size, String table){
    super(size, "Table", table);
  }
}
