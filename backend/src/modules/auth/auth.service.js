import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import authRepository from './auth.repository.js';
import { UnauthorizedError, NotFoundError } from '../../utils/errors.js';
import { config } from '../../config/env.js';

export class AuthService {
  async login(email, password) {
    const user = await authRepository.findByEmail(email);

    if (!user || !user.is_active) {
      throw new UnauthorizedError('Email atau password salah');
    }

    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      throw new UnauthorizedError('Email atau password salah');
    }

    const tokenPayload = {
      userId: user.id,
      role: user.role,
      tenantId: user.tenant_id,
      vendorId: user.vendor_id,
    };

    const token = jwt.sign(tokenPayload, config.jwt.secret, {
      expiresIn: config.jwt.expiresIn,
    });

    return {
      token,
      user: {
        id: user.id,
        tenant_id: user.tenant_id,
        vendor_id: user.vendor_id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
      },
    };
  }

  async getMe(userId) {
    const user = await authRepository.findById(userId);
    if (!user || !user.is_active) {
      throw new NotFoundError('Pengguna tidak ditemukan atau tidak aktif');
    }

    return {
      id: user.id,
      tenant_id: user.tenant_id,
      vendor_id: user.vendor_id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      role: user.role,
      created_at: user.created_at,
      updated_at: user.updated_at,
    };
  }
}

export default new AuthService();
