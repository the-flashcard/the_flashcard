import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:tf_core/tf_core.dart';

typedef Func0 = void Function();
typedef Func1<T> = void Function(T v);
typedef Func2<T1, T2> = void Function(T1 v1, T2 v2);
typedef Func3<T1, T2, T3> = void Function(T1 v1, T2 v2, T3 v3);
typedef Func4<T1, T2, T3, T4> = void Function(T1 v1, T2 v2, T3 v3, T4 v4);
typedef ErrorHandler = void Function(BuildContext context, Exception ex);

class XError {
  static void defaultErrorHandler(prefix0.BuildContext context, Exception ex) {
    if (context != null) {
      Scaffold.of(context).removeCurrentSnackBar();
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: prefix0.Text(Config.getString("msg_something_went_wrong")),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static void f0(Func0 f, {ErrorHandler errorHandler, BuildContext context}) {
    try {
      f();
    } catch (e) {
      Log.error(e);
      try {
        if (context != null) {
          if (errorHandler != null)
            errorHandler(context, e);
          else
            defaultErrorHandler(context, e);
        }
      } catch (e2) {
        Log.error(e2);
      }
    }
  }

  static void f1<T>(Func1<T> f, T value,
      {ErrorHandler errorHandler, BuildContext context}) {
    try {
      f(value);
    } catch (e) {
      Log.error(e);
      if (context != null) {
        if (errorHandler != null)
          errorHandler(context, e);
        else
          defaultErrorHandler(context, e);
      }
    }
  }

  static void f2<T1, T2>(Func2<T1, T2> f, T1 v1, T2 v2,
      {ErrorHandler errorHandler, BuildContext context}) {
    try {
      f(v1, v2);
    } catch (e) {
      Log.error(e);
      if (context != null) {
        if (errorHandler != null)
          errorHandler(context, e);
        else
          defaultErrorHandler(context, e);
      }
    }
  }

  static void f3<T1, T2, T3>(Func3<T1, T2, T3> f, T1 v1, T2 v2, T3 v3,
      {ErrorHandler errorHandler, BuildContext context}) {
    try {
      f(v1, v2, v3);
    } catch (e) {
      Log.error(e);
      if (context != null) {
        if (errorHandler != null)
          errorHandler(context, e);
        else
          defaultErrorHandler(context, e);
      }
    }
  }

  static void f4<T1, T2, T3, T4>(
      Func4<T1, T2, T3, T4> f, T1 v1, T2 v2, T3 v3, T4 v4,
      {ErrorHandler errorHandler, BuildContext context}) {
    try {
      f(v1, v2, v3, v4);
    } catch (e) {
      Log.error(e);
      if (context != null) {
        if (errorHandler != null)
          errorHandler(context, e);
        else
          defaultErrorHandler(context, e);
      }
    }
  }
}
