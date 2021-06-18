<?php

namespace App\Repository\Contracts;

interface PostsRepository {
    public function getAllPosts(): array;
}
