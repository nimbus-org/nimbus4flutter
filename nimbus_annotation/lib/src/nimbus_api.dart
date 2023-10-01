import 'package:meta/meta.dart';

/// A holder that includes all http methods which are supported by retrofit.
class NimbusHttpMethod {
  static const String GET = 'GET';
  static const String POST = 'POST';
  static const String PATCH = 'PATCH';
  static const String PUT = 'PUT';
  static const String DELETE = 'DELETE';
  static const String HEAD = 'HEAD';
  static const String OPTIONS = 'OPTIONS';
}

class NimbusApi {
  const NimbusApi({this.baseUrl});

  final String? baseUrl;
}

@immutable
class Method {
  const Method(
    this.method,
    this.path,
  );

  /// HTTP request method which can be found in [HttpMethod].
  final String method;

  /// A relative or absolute path, or full URL of the endpoint.
  ///
  /// See [RestApi.baseUrl] for details of how this is resolved against a base URL
  /// to create the full endpoint URL.
  final String path;
}

/// Make a `GET` request
///
/// ```
/// @GET("ip")
/// Future<String> ip(@Query('query1') String query)
/// ```
@immutable
class GET extends Method {
  const GET(String path) : super(NimbusHttpMethod.GET, path);
}

/// Make a `POST` request
@immutable
class POST extends Method {
  const POST(String path) : super(NimbusHttpMethod.POST, path);
}

/// Make a `PATCH` request
@immutable
class PATCH extends Method {
  const PATCH(final String path) : super(NimbusHttpMethod.PATCH, path);
}

/// Make a `PUT` request
@immutable
class PUT extends Method {
  const PUT(final String path) : super(NimbusHttpMethod.PUT, path);
}

/// Make a `DELETE` request
@immutable
class DELETE extends Method {
  const DELETE(final String path) : super(NimbusHttpMethod.DELETE, path);
}

/// Make a `HEAD` request
@immutable
class HEAD extends Method {
  const HEAD(String path) : super(NimbusHttpMethod.HEAD, path);
}

/// Make a `OPTIONS` request
@immutable
class OPTIONS extends Method {
  const OPTIONS(String path) : super(NimbusHttpMethod.OPTIONS, path);
}

/// Adds headers specified in the [value] map.
@immutable
class Headers {
  const Headers([this.value]);

  final Map<String, dynamic>? value;
}

/// Replaces the header with the value of its target.
///
/// Header parameters may be `null` which will omit them from the request.
@immutable
class Header {
  const Header(this.value);

  final String value;
}

/// Use this annotation on a service method param when you want to directly control the request body
/// of a POST/PUT request (instead of sending in as request parameters or form-style request
/// body).
///
/// Body parameters may not be `null`.
@immutable
class Body {
  const Body({this.nullToAbsent = false});

  final bool nullToAbsent;
}

/// Use this annotation on a service method param when you want to indicate that no body should be
/// generated for POST/PUT/DELETE requests.
@immutable
class NoBody {
  const NoBody();
}

/// Named pair for a form request.
///
/// ```
/// @POST("/post")
/// Future<String> example(
///   @Field() int foo,
///   @Field("bar") String barbar},
/// )
/// ```
/// Calling with `foo.example("Bob Smith", "President")` yields a request body of
/// `foo=Bob+Smith&bar=President`.
@immutable
class Field {
  const Field([this.value]);

  final String? value;
}

/// Named replacement in a URL path segment.
///
/// Path parameters may not be `null`.
@immutable
class Path {
  const Path([this.value]);

  final String? value;
}

/// Query parameter appended to the URL.
///
/// Simple Example:
///
///```
/// @GET("/get")
/// Future<String> foo(@Query('bar') String query)
///```
/// Calling with `foo.friends(1)` yields `/get?bar=1`.
@immutable
class Query {
  const Query(this.value, {this.encoded = false});

  final String value;
  final bool encoded;
}

/// Query parameter keys and values appended to the URL.
///
/// A `null` value for the map, as a key, or as a value is not allowed.
@immutable
class Queries {
  const Queries({this.encoded = false});

  final bool encoded;
}

/// An interface for annotation which has mime type.
/// Such as [FormUrlEncoded] and [MultiPart].
abstract class _MimeType {
  const _MimeType();

  abstract final String mime;
}

/// Denotes that the request body will use form URL encoding. Fields should be declared as
/// parameters and annotated with [Field].
///
/// Requests made with this annotation will have `application/x-www-form-urlencoded` MIME
/// type. Field names and values will be UTF-8 encoded before being URI-encoded in accordance to
/// [RFC-3986](http://tools.ietf.org/html/rfc3986)
@immutable
class FormUrlEncoded extends _MimeType {
  const FormUrlEncoded();

  @override
  final String mime = 'application/x-www-form-urlencoded';
}

/// Denotes that the request body is multi-part. Parts should be declared as parameters and
/// annotated with [Part].
@immutable
class MultiPart extends _MimeType {
  const MultiPart();

  @override
  final String mime = 'multipart/form-data';
}

/// Denotes a single part of a multi-part request.
/// Part parameters may not be null.
/// ```
/// @POST("/post")
/// @MultiPart()
/// Future<String> example(
///   @Part() int foo,
///   { @Part(name: "bar") String barbar,
///     @Part(contentType:'application/json') File file
///   },
/// )
/// ```
@immutable
class Part {
  const Part({
    @Deprecated('future release') this.value,
    this.name,
    this.fileName,
    this.contentType,
  });

  @Deprecated('future release')
  final String? value;
  final String? name;

  /// If this field is a file, optionally specify it's name. otherwise the name
  /// will be derived from the actual file.
  final String? fileName;

  // To identify the content type of a file
  final String? contentType;
}

@immutable
class CacheControl {
  const CacheControl({
    this.maxAge,
    this.maxStale,
    this.minFresh,
    this.noCache = false,
    this.noStore = false,
    this.noTransform = false,
    this.onlyIfCached = false,
    this.other = const [],
  });

  final int? maxAge;
  final int? maxStale;
  final int? minFresh;
  final bool noCache;
  final bool noStore;
  final bool noTransform;
  final bool onlyIfCached;
  final List<String> other;
}