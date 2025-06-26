// lib/domain/core/type_defs.dart

import 'package:fpdart/fpdart.dart';
import 'package:mincloset/domain/failures/failures.dart';

// Định nghĩa một kiểu 'FutureEither' cho các hàm bất đồng bộ trả về
// một giá trị T hoặc một Failure.
typedef FutureEither<T> = Future<Either<Failure, T>>;

// Định nghĩa một kiểu 'FutureEitherVoid' cho các hàm bất đồng bộ
// không trả về giá trị gì khi thành công (tương đương void).
typedef FutureEitherVoid = FutureEither<Unit>;