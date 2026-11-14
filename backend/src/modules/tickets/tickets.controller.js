import ticketService from './tickets.service.js';
import { sendCreated, sendSuccess } from '../../utils/response.js';

export class TicketController {
  async updateStatus(req, res, next) {
    try {
      const ticketId = parseInt(req.params.id, 10);
      const { to_status, note } = req.body;
      const ticket = await ticketService.updateStatus(req.auth, ticketId, to_status, note);
      return sendSuccess(res, ticket);
    } catch (error) {
      next(error);
    }
  }

  async assignTicket(req, res, next) {
    try {
      const ticketId = parseInt(req.params.id, 10);
      const { technician_id } = req.body;
      const ticket = await ticketService.assignTicket(req.auth, ticketId, technician_id);
      return sendSuccess(res, ticket);
    } catch (error) {
      next(error);
    }
  }

  async forwardTicket(req, res, next) {
    try {
      const ticketId = parseInt(req.params.id, 10);
      const { vendor_id } = req.body;
      const ticket = await ticketService.forwardTicket(req.auth, ticketId, vendor_id);
      return sendSuccess(res, ticket);
    } catch (error) {
      next(error);
    }
  }

  async updateTicket(req, res, next) {
    try {
      const ticketId = parseInt(req.params.id, 10);
      const ticket = await ticketService.updateTicket(req.auth, ticketId, req.body);
      return sendSuccess(res, ticket);
    } catch (error) {
      next(error);
    }
  }

  async getTicketById(req, res, next) {
    try {
      const ticketId = parseInt(req.params.id, 10);
      const ticket = await ticketService.getTicketById(req.auth, ticketId);
      return sendSuccess(res, ticket);
    } catch (error) {
      next(error);
    }
  }

  async getTicketHistories(req, res, next) {
    try {
      const ticketId = parseInt(req.params.id, 10);
      const histories = await ticketService.getTicketHistories(req.auth, ticketId);
      return sendSuccess(res, histories);
    } catch (error) {
      next(error);
    }
  }

  async getTickets(req, res, next) {
    try {
      const result = await ticketService.getTickets(req.auth, req.query);
      return sendSuccess(res, result.data, 200, result.meta);
    } catch (error) {
      next(error);
    }
  }

  async createTicket(req, res, next) {
    try {
      const ticket = await ticketService.createTicket(req.auth, req.body);
      return sendCreated(res, ticket);
    } catch (error) {
      next(error);
    }
  }

  async uploadPhoto(req, res, next) {
    try {
      const ticketId = parseInt(req.params.id, 10);
      const caption = req.body?.caption || null;
      const photo = await ticketService.uploadPhoto(req.auth, ticketId, req.file, caption);
      return sendCreated(res, photo);
    } catch (error) {
      next(error);
    }
  }
}

export default new TicketController();
