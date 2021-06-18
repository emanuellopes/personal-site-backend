<?php

namespace App\Http\Controllers;

use App\Repository\Contracts\PostsRepository;

class Post extends Controller {
    private PostsRepository $posts_repository;

    public function __construct( PostsRepository $posts_repository ) {
        $this->posts_repository = $posts_repository;
    }

    public function index() {
        $posts = $this->posts_repository->getAllPosts();

        return $this->successResponse( $posts );
    }
}
