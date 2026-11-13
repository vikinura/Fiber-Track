import ticketService from './tickets.service.js';
import { sendCreated, sendSuccess } from '../../utils/response.js';

export class TicketController {
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
}

export default new TicketController();
