/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import java.io.ByteArrayOutputStream;

/**
 * Library of utility methods useful in dealing with converting byte arrays to
 * and from strings of hexadecimal digits.
 * 
 * @author Craig R. McClanahan
 */

public class Utils {
  /**
   * Convert a byte array into a printable format containing a String of
   * hexadecimal digit characters (two per byte).
   * 
   * @param bytes
   *          Byte array representation
   */
  public static String convert(byte bytes[]) {

    StringBuffer sb = new StringBuffer(bytes.length * 2);
    for (int i = 0; i < bytes.length; i++) {
      sb.append(convertDigit((int) (bytes[i] >> 4)));
      sb.append(convertDigit((int) (bytes[i] & 0x0f)));
    }
    return (sb.toString());

  }

  /**
   * [Private] Convert the specified value (0 .. 15) to the corresponding
   * hexadecimal digit.
   * 
   * @param value
   *          Value to be converted
   */
  private static char convertDigit(int value) {

    value &= 0x0f;
    if (value >= 10)
      return ((char) (value - 10 + 'a'));
    else
      return ((char) (value + '0'));
  }
}