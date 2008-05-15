/*****************************************************************************
 * Copyright (C) PicoContainer Organization. All rights reserved.            *
 * ------------------------------------------------------------------------- *
 * The software in this package is published under the terms of the BSD      *
 * style license a copy of which has been included with this distribution in *
 * the LICENSE.txt file.                                                     *
 *****************************************************************************/
package org.picocontainer.gems.monitors;

import java.lang.reflect.Constructor;
import java.lang.reflect.Method;
import java.io.IOException;

import org.picocontainer.ComponentMonitor;

/**
 * @author Paul Hammant
 * @author Mauro Talevi
 */
public class SingleLoggerSlf4JComponentMonitorTestCase extends ComponentMonitorHelperTestCase {

    protected ComponentMonitor makeComponentMonitor() {
        return new Slf4jComponentMonitor(Slf4jComponentMonitor.class);
    }

    protected Constructor getConstructor() throws NoSuchMethodException {
        return getClass().getConstructor((Class[])null);
    }

    protected Method getMethod() throws NoSuchMethodException {
        return getClass().getDeclaredMethod("makeComponentMonitor", (Class[])null);
    }

    protected String getLogPrefix() {
        return "[" + Slf4jComponentMonitor.class.getName() + "] ";
    }

    public void testShouldTraceNoComponent() throws IOException {
        super.testShouldTraceNoComponent();    
    }
        
}
