package com.nearinfinity.agent.exceptions;

@SuppressWarnings("serial")
public class TableMissingException extends MissingException {
  public TableMissingException(String table)
  {
    super("Table", table);
  }
}
