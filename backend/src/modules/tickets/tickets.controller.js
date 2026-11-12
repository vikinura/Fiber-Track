import ticketService from './tickets.service.js';
import { sendCreated } from '../../utils/response.js';

export class TicketController {
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
