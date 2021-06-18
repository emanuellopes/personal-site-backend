<?php

namespace App\Traits;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Response;

trait ApiResponse
{
    public function successResponse($data, $code = Response::HTTP_OK): JsonResponse
    {
        return \response()->json(['data' => $data], $code);
    }

    public function errorResponse($message, $code): JsonResponse
    {
        return \response()->json(['error' => $message, 'code' => $code], $code);
    }
}
