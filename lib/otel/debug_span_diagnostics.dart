// ignore_for_file: avoid_print

import 'dart:async';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:flutter/foundation.dart';
import 'package:middleware_flutter_opentelemetry/middleware_flutter_opentelemetry.dart';

/// Comprehensive diagnostic tool for OpenTelemetry span processing issues
class OTelSpanDiagnostics {
  static void runFullDiagnostics() {
    if (!kDebugMode) return;

    print('🔍 === COMPREHENSIVE OTEL SPAN DIAGNOSTICS ===');
    print('');

    try {
      _checkTracerProviderSetup();
      _checkSpanProcessors();
      _checkTracerInstances();
      _testSpanCreation();
      _checkSpanExecution();
    } catch (e, stack) {
      print('❌ Error during diagnostics: $e');
      print('Stack: $stack');
    }

    print('');
    print('🔍 === END SPAN DIAGNOSTICS ===');
  }

  static void _checkTracerProviderSetup() {
    print('1️⃣ TRACER PROVIDER SETUP');
    print('========================');

    final tracerProvider = FlutterOTel.tracerProvider;
    print('TracerProvider type: ${tracerProvider.runtimeType}');
    print('TracerProvider hashCode: ${tracerProvider.hashCode}');
    print('Span processors count: ${tracerProvider.spanProcessors.length}');

    // Check global tracer provider
    final globalProvider = OTel.tracerProvider();
    print('Global TracerProvider type: ${globalProvider.runtimeType}');
    print('Global TracerProvider hashCode: ${globalProvider.hashCode}');
    print('Same instance? ${tracerProvider == globalProvider}');
    print('');
  }

  static void _checkSpanProcessors() {
    print('2️⃣ SPAN PROCESSORS');
    print('==================');

    final tracerProvider = FlutterOTel.tracerProvider;

    if (tracerProvider.spanProcessors.isEmpty) {
      print('❌ NO SPAN PROCESSORS FOUND!');
      print('This is the root cause - spans have nowhere to go');
      return;
    }

    for (int i = 0; i < tracerProvider.spanProcessors.length; i++) {
      final processor = tracerProvider.spanProcessors[i];
      print('Processor $i:');
      print('  Type: ${processor.runtimeType}');
      print('  HashCode: ${processor.hashCode}');

      // Check if it's a BatchSpanProcessor
      if (processor.runtimeType.toString().contains('BatchSpanProcessor')) {
        print('  ✅ Found BatchSpanProcessor');
        _inspectBatchSpanProcessor(processor);
      }
    }
    print('');
  }

  static void _inspectBatchSpanProcessor(dynamic processor) {
    try {
      // Try to access internal state via reflection if possible
      print('  Inspecting BatchSpanProcessor internals...');

      // This might not work due to private fields, but worth trying
      final processorString = processor.toString();
      print('  String representation: $processorString');
    } catch (e) {
      print('  Cannot inspect internal state: $e');
    }
  }

  static void _checkTracerInstances() {
    print('3️⃣ TRACER INSTANCES');
    print('===================');

    final tracer = FlutterOTel.tracer;
    print('Tracer type: ${tracer.runtimeType}');
    print('Tracer provider type: ${tracer.provider.runtimeType}');
    print('Tracer provider hashCode: ${tracer.provider.hashCode}');

    final globalTracer = OTel.tracer();
    print('Global tracer type: ${globalTracer.runtimeType}');
    print('Same tracer? ${tracer == globalTracer}');
    print('Same provider? ${tracer.provider == FlutterOTel.tracerProvider}');
    print('');
  }

  static void _testSpanCreation() {
    print('4️⃣ SPAN CREATION TEST');
    print('=====================');

    try {
      final tracer = FlutterOTel.tracer;

      // Create a test span with detailed logging
      print('Creating test span...');
      final span = tracer.startSpan(
        'diagnostic_test_span',
        attributes: <String, Object>{
          'test.diagnostic': true,
          'test.timestamp': DateTime.now().millisecondsSinceEpoch,
        }.toAttributes(),
      );

      print('✅ Span created successfully');
      print('Span type: ${span.runtimeType}');
      print('Span context: ${span.spanContext}');
      print('Span trace ID: ${span.spanContext.traceId}');
      print('Span span ID: ${span.spanContext.spanId}');

      // Add some events and attributes
      span.addEventNow(
          'diagnostic_event',
          <String, Object>{
            'event.test': true,
          }.toAttributes());

      span.addAttributes(<String, Object>{
        'test.updated': true,
      }.toAttributes());

      print('📝 Added event and attributes');

      // End the span
      print('Ending span...');
      span.end();
      print('✅ Span ended');
    } catch (e, stack) {
      print('❌ Error creating/ending span: $e');
      print('Stack: $stack');
    }
    print('');
  }

  static void _checkSpanExecution() {
    print('5️⃣ SPAN EXECUTION CHECK');
    print('=======================');

    // Force flush to see if anything happens
    print('Forcing flush...');
    try {
      FlutterOTel.tracerProvider.forceFlush();
      print('✅ Force flush completed');
    } catch (e) {
      print('❌ Error during force flush: $e');
    }

    // Check if spans are reaching exporters
    print('');
    print('🔍 DEBUGGING TIPS:');
    print('------------------');
    print(
        '1. If "NO SPAN PROCESSORS FOUND" - the processor isn\'t being added');
    print(
        '2. If processors exist but spans don\'t export - check exporter configuration');
    print('3. If different provider instances - initialization order issue');
    print('4. Add breakpoints in BatchSpanProcessor._exportBatch() method');
    print('5. Check if OTelLog.enableTraceLogging() is called');
    print('');
  }

  /// Call this from a button or timer to monitor ongoing span processing
  static void monitorSpanProcessing() {
    if (!kDebugMode) return;

    print('📊 Monitoring span processing...');

    // Create multiple test spans to trigger batch processing
    for (int i = 0; i < 5; i++) {
      final span = FlutterOTel.tracer.startSpan(
        'monitor_test_span_$i',
        attributes: <String, Object>{
          'test.batch': i,
          'test.monitor': true,
        }.toAttributes(),
      );

      span.addEventNow('monitor_event_$i');
      span.end();
    }

    print('📤 Created 5 test spans');

    // Force flush and see what happens
    Timer(Duration(seconds: 2), () {
      print('🔄 Forcing flush after 2 seconds...');
      FlutterOTel.tracerProvider.forceFlush();
    });
  }
}

/// Extension to easily run diagnostics from anywhere
extension OTelDiagnosticsExtension on FlutterOTel {
  static void runDiagnostics() {
    OTelSpanDiagnostics.runFullDiagnostics();
  }

  static void monitorSpans() {
    OTelSpanDiagnostics.monitorSpanProcessing();
  }
}
