<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use App\Models\User;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
            'device_id' => 'required|string'
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Email atau Password salah!'
            ], 401);
        }

        if ($user->role === 'admin') {
        return response()->json([
            'success' => false,
            'message' => 'Akun Admin tidak diizinkan masuk melalui aplikasi seluler.'
        ], 403);
    }

        if (is_null($user->device_id)) {
            $user->update(['device_id' => $request->device_id]);
        } else if ($user->device_id !== $request->device_id) {
            return response()->json([
                'success' => false,
                'message' => 'Akses Ditolak! Akun Anda sudah terkunci di perangkat lain. Hubungi Admin jika Anda ganti HP.'
            ], 403);
        }

        $user->tokens()->delete();

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login Berhasil',
            'data' => $user,
            'token' => $token
        ], 200);
    }

    public function logout(Request $request)
    {
        $request->user()->update([
            'fcm_token' => null
        ]);

        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logout Berhasil'
        ], 200);
    }

    public function updatePhoto(Request $request)
    {
        $request->validate([
            'image' => 'required|image|mimes:jpeg,png,jpg|max:2048'
        ]);

        $user = $request->user();

        if ($request->hasFile('image')) {
            $path = $request->file('image')->store('profiles', 'public');

            $user->photo = $path;
            $user->save();

            return response()->json([
                'success' => true,
                'message' => 'Foto profil berhasil diperbarui',
                'photo_path' => $path
            ], 200);
        }

        return response()->json(['success' => false, 'message' => 'Gagal mengunggah foto'], 400);
    }

    public function changePassword(Request $request)
    {
        $request->validate([
            'old_password' => 'required',
            'new_password' => 'required|min:6|different:old_password|confirmed',
        ]);

        $user = $request->user();

        if (!\Hash::check($request->old_password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Kata sandi lama yang Anda masukkan salah.'
            ], 400);
        }

        $user->password = \Hash::make($request->new_password);
        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'Kata sandi berhasil diperbarui!'
        ], 200);
    }

    public function updateProfile(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email,' . $request->user()->id,
            'phone' => 'required|string|max:20',
            'address' => 'nullable|string',
        ]);

        $user = $request->user();
        $user->name = $request->name;
        $user->email = $request->email;
        $user->phone = $request->phone;
        if ($request->has('address')) {
            $user->address = $request->address;
        }

        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'Profil berhasil diperbarui!',
            'data' => clone $user
        ], 200);
    }

    public function saveToken(Request $request)
    {
        $request->validate([
            'fcm_token' => 'required|string'
        ]);

        $request->user()->update([
            'fcm_token' => $request->fcm_token
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Token FCM berhasil disimpan.'
        ]);
    }
}