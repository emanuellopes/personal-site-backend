<?php

namespace App\Exceptions;

use App\Traits\ApiResponse;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Http\Response;
use Illuminate\Validation\ValidationException;
use Laravel\Lumen\Exceptions\Handler as ExceptionHandler;
use Symfony\Component\HttpKernel\Exception\HttpException;
use Throwable;

class Handler extends ExceptionHandler {

    use ApiResponse;

    /**
     * A list of the exception types that should not be reported.
     *
     * @var array
     */
    protected $dontReport
        = [
            AuthorizationException::class,
            HttpException::class,
            ModelNotFoundException::class,
            ValidationException::class,
        ];

    /**
     * Report or log an exception.
     *
     * This is a great spot to send exceptions to Sentry, Bugsnag, etc.
     *
     * @param  \Throwable  $exception
     *
     * @return void
     *
     * @throws \Exception
     */
    public function report( Throwable $exception ) {
        parent::report( $exception );
    }

    /**
     * Render an exception into an HTTP response.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Throwable  $exception
     *
     * @return \Illuminate\Http\Response|\Illuminate\Http\JsonResponse
     *
     * @throws \Throwable
     */
    public function render( $request, Throwable $exception ) {
        if ( $exception instanceof ModelNotFoundException ) {
            return $this->errorResponse( $exception->getMessage(),
                Response::HTTP_NOT_FOUND );
        }

        if ( $exception instanceof HttpException ) {
            $message = $exception->getMessage();

            return $this->errorResponse( empty( $message )
                ? 'Invalid parameters' : $message,
                $exception->getStatusCode() );
        }

        if ( $exception instanceof ValidationException ) {
            return $this->errorResponse( $exception->errors(),
                Response::HTTP_NOT_FOUND );
        }

        if ( true === env( 'APP_DEBUG' ) ) {
            return parent::render( $request, $exception );
        }

        return $this->errorResponse( 'Unexpected error. Try Later',
            Response::HTTP_INTERNAL_SERVER_ERROR );
    }
}
