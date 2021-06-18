<?php

namespace App\Providers;

use App\Repository\PostsRepository;
use Illuminate\Support\ServiceProvider;
use App\Repository\Contracts\PostsRepository as PostRepositoryContract;

class RepositoryServiceProvider extends ServiceProvider {
    public function register() {
        $this->app->bind( PostRepositoryContract::class,
            PostsRepository::class );
    }
}
